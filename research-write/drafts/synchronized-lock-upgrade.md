# synchronized 的锁升级：HotSpot 里到底发生了什么

> **TL;DR**  
> HotSpot 在对象头 Mark Word 上分级加锁，能不进内核就不进。  
> **JDK 8～14**：无锁 → 偏向 → 轻量 → 重量；**JDK 15+** 偏向锁默认关；**JDK 22+** 还有轻量锁新实现、ObjectMonitorTable；**JDK 24+** 虚拟线程 **阻塞在监视器上** 时钉住（pinning）问题大幅缓解（[JEP 491](https://openjdk.org/jeps/491)）。  
> 建议顺序：§2 选版本 → §3–§5 经典（§4 位布局）→ §6 示例 → §7 误区 → **§8.1.1（JDK 15～21 必读）** → §8.2（JDK 22+）→ §9 → §10 → §11 自检。

---

## 1. 为什么 synchronized 要分级加锁

`synchronized` 就是语言里的 **监视器（monitor）**：**同一时刻只有一个线程能持有锁**。

如果每次加锁都直接走 **`ObjectMonitor`**（重量级监视器），线程可能要 **阻塞在操作系统互斥量** 上，再经历内核调度，进出一小段临界区的成本就很高。HotSpot 的做法是：**先在对象头 Mark Word 上用 CAS、自旋等用户态手段抢锁**；只有争用上来，或需要 `wait` / `notify` 等完整监视器能力时，才把对象 **膨胀（inflate）** 到 `ObjectMonitor`。

可以粗记两条线：

| 路径 | 典型代价 | 何时够用 |
|------|----------|----------|
| Mark Word（无锁 / 偏向* / 轻量） | 用户态 CAS、少量自旋 | 临界区短、争用少 |
| ObjectMonitor（重量） | 监视器队列、可能进内核阻塞 | 多线程互斥、`wait` / `notify` |

口语里的 **锁升级**，多半指争用加剧时从 Mark Word 路径 **胀到 ObjectMonitor**；**不是**对称地「解锁后再一级级降回去」（§7）。

\* **JDK 15+ 默认无偏向**（§2、§8.1），线上 Mark Word 路径常见为无锁 ↔ fast-lock（`00`）↔ monitor（`10`）。

---

## 2. 版本路线图：你的 JDK 该信哪套叙事

看机制前先对号入座——**别把 JDK 8 八股直接套线上 LTS**。

**怎么用本节：** 先看你跑的是哪一列「版本」，再按「本文读法」决定 §4–§5 要不要读偏向、§8/§9 要不要细读。面试题里常考四阶段，但 **线上默认路径以你 JDK 那一列为准**。

| 版本 | 默认路径 | 本文读法 |
|------|----------|----------|
| **JDK 8～14** | 无锁 → 偏向 → 轻量 → 重量 | §5 四阶段 + §4 Mark Word 位布局 |
| **JDK 15～17** | 默认无偏向；偏向锁参数已弃用 | 四阶段 **跳过 §5.2**；老系统若显式开过偏向锁，查启动参数 |
| **JDK 18～21** | 偏向锁参数已废弃 / 被忽略；无锁 → fast-lock → ObjectMonitor | 四阶段 **面试仍考**；线上走 **§8.1.1**（跳过偏向）；别硬套 §4 每一位 |
| **JDK 21～23 + 虚拟线程** | 在 `synchronized` 内阻塞会钉住载体线程 | §9（与上行 LTS 交叉：21 既在此也在 §8） |
| **JDK 22+** | 轻量锁新实现、ObjectMonitorTable | §4/§5 **勿硬套**；§8.2 + **§8.2.1**（重量形态）；以版本标签 `markWord.hpp` 为准 |
| **JDK 24+** | [JEP 491](https://openjdk.org/jeps/491) 改善阻塞时的卸载 | §9 |

**JDK 17 / 21 LTS** 还很多，但都不该默认「偏向锁开着」；它们也不等于 JDK 22 的轻量锁新实现全貌。

---

## 3. 语言层：监视器是什么（JLS）

[JLS 17.1](https://docs.oracle.com/javase/specs/jls/se17/html/jls-17.html#jls-17.1) 规定：每个对象关联一个监视器；线程进入 `synchronized` 时 **加锁（lock）**，退出时 **解锁（unlock）**；**同一线程可以重入**——对同一把锁连续 `synchronized` 不会把自己挡在外面。

```java
public void transfer(Account from, Account to, long amount) {
    synchronized (from) {
        synchronized (to) {
            from.debit(amount);
            to.credit(amount);
        }
    }
}
```

编译后，每个 `synchronized` 块对应 **`monitorenter` / `monitorexit`** 字节码（方法级 `synchronized` 则体现在方法访问标志上，语义相同）。JVM 实现时：

- **语言层**：你只关心「进了监视器 / 出了监视器」。
- **实现层**：HotSpot 在 **Mark Word** 上记「当前是哪种锁、谁持有」；尽量在用户态完成，**不是**每次 `monitorenter` 都等价于一次内核 mutex。

重入时，重量路径会在 `ObjectMonitor` 上增加 **递归计数**；轻量 / 偏向路径也有对应的「同线程再进」处理，细节在 §5，位布局在 §4。

---

## 4. 对象头：Mark Word 与锁状态（JDK 8）

要读懂 §5 的四阶段，得先弄清一件事：**锁状态不是单独挂在对象旁边的字段，而是写在每个对象头上的 Mark Word 里。** 线程进 `synchronized` 时，HotSpot 读写的主要是这 8 个字节（64 位 JVM 下）。

### 4.1 对象头里有什么

在 **64 位 HotSpot** 里，一个普通 Java 对象在堆上的头部通常可以粗分为两块（具体是否压缩 klass 取决于 `-XX:+UseCompressedOops` 等开关，这里不展开）：

```text
  堆上的对象
  ┌──────────────────┬──────────────────┐
  │   Mark Word      │  Klass 指针      │  ← 对象头（instanceOop）
  │   8 字节         │  8 或 4 字节     │
  └──────────────────┴──────────────────┘
  │  实例字段 …                          │
```

- **Klass 指针**：这个对象是哪个类的实例（类型信息）。
- **Mark Word**：运行时杂项——GC 分代年龄、哈希码（延迟计算时）、**以及 synchronized 用的锁状态**。同一块 64 位里，**不同锁状态下存的语义不同**；不是「永远有一个叫 lock_state 的独立子结构」。

下面只讲 **普通对象（normal object）** 在 JDK 8 里和锁相关的编码；数组、转发指针等别的 Mark Word 布局见源码注释，本文不展开。

### 4.2 用最低 3 位认「当前是哪种锁」

[JDK 8u `markOop.hpp`](https://github.com/openjdk/jdk8u/blob/master/hotspot/src/share/vm/oops/markOop.hpp) 用 **2 位 lock + 1 位 biased** 区分状态（读源码时记 `lock_mask` / `biased_lock_pattern`）：

| lock（2 位） | biased（1 位） | 合称（常记法） | 状态 | 对象头上的 Mark Word 在表达什么 |
|--------------|----------------|----------------|------|----------------------------------|
| `01` | `0` | `001` | **无锁** | 未加锁；高位还可放 hash、GC age 等（见下） |
| `01` | `1` | `101` | **偏向锁** | 已「偏心」到某条线程；高位主要是 **JavaThread***、epoch、age |
| `00` | — | `00` + 指针 | **轻量级锁** | 整个 Mark Word 变成 **指向栈上锁记录的指针**（低位 `00`） |
| `10` | — | `10` + 指针 | **重量级锁** | 整个 Mark Word 变成 **指向 ObjectMonitor 的指针**（低位 `10`） |

容易混的一点：**无锁和偏向锁的 lock 位都是 `01`，靠 biased 位区分**——无锁是 `…0|01`，偏向是 `…1|01`（表里写成 `001` / `101` 是连低位一起看的习惯写法）。

一旦进入轻量或重量锁，**原来无锁时写在 Mark Word 高位里的 hash / age 等不能再照旧留在对象头上**（位被指针占了），所以轻量路径会把「旧 Mark Word」先备份到别处——这就是下一节的 **置换头（displaced header）**。

### 4.3 四种状态下，Mark Word 长什么样（位域示意）

注释里的布局（**低位在右侧**；`[` 内是高位 → 低位方向，与 `markOop.hpp` 一致）：

```text
 64-bit normal object Mark Word

 unlocked     [ hash:31 | age:4 | 0 | 01 ]     无锁：能存哈希、分代年龄
 biased       [ thread:54 | epoch:2 | age:4 | 1 | 01 ]   偏向：记「偏向谁」
 lightweight  [ ptr to Lock Record ........ | 00 ]     轻量：对象头 → 栈上锁记录
 heavyweight  [ ptr to ObjectMonitor ...... | 10 ]     重量：对象头 → 监视器
```

读图时可以抓住三条线：

1. **无锁 `001`**：对象刚 `new` 出来、还没人 `synchronized` 时，一般是这种；低位固定 `01`，biased=0。
2. **偏向 `101`**：同一线程反复加锁且偏向成功时，对象头上直接记着「我偏向哪条线程」，再次进入往往只做检查，不必立刻 CAS 抢轻量锁（§5.2）。
3. **轻量 `00` / 重量 `10`**：对象头 **不再** 同时保留完整的 hash/age 位图，而是 **整段当成指针** 用（所以必须先备份旧值）。

### 4.4 轻量锁为什么要「置换头」（和对象头、栈的关系）

轻量锁是初学者最容易卡住的地方：**加锁成功后，对象头上的 Mark Word 已经不是「无锁那一版」了，而是指向当前线程栈里的一条锁记录。**

可以想成两步（对应 §5.3，这里只画数据流）：

```text
  加锁前（无锁）                    加锁成功后（轻量级锁）
  对象.markWord = [hash|age|01]     对象.markWord = [ptr → Lock Record | 00]
                                           │
                                           ▼
                                    栈上的 Lock Record
                                    ┌─────────────────────┐
                                    │ displaced header    │ ← 拷贝来的「旧 Mark Word」
                                    │   (= 置换头)        │
                                    │ owner / 其他字段…   │
                                    └─────────────────────┘
```

- **置换头**：锁记录里保存的那份 **原始 Mark Word**（无锁时的 hash、age、`01` 等）。解锁时若还是轻量路径、且没有别人抢锁，JVM 用 CAS 把对象头 **恢复成置换头**，对象回到无锁外观。
- **为什么要拷走**：对象头 64 位要用来放「指向锁记录的指针」，没地方同时保留原来的 hash/age；不备份就丢信息。

所以：**「锁升级」在对象头上的可见变化，往往就是 Mark Word 从 `001` / `101` 变成 `00+栈指针`，再变成 `10+监视器指针`**——不是对象旁边多了一个 lock 字段。

### 4.5 和 §5 四阶段怎么对上号

| §5 阶段 | 本节对应 | 对象头上典型低位 / 形态 |
|---------|----------|-------------------------|
| 无锁 | §4.3 第一行 | 低位 `01`，biased=0（常记 `001`） |
| 偏向 | §4.3 第二行 | 低位 `01`，biased=1（常记 `101`），记着 JavaThread* |
| 轻量 | §4.3 第三行 + §4.4 | 对象头为「锁记录指针 + 00」，置换头在栈上 |
| 重量 | §4.3 第四行 | 对象头为「ObjectMonitor 指针 + 10」 |

§5 的流程图描述的是 **争用加剧时状态怎么跳**；本节是 **每一格状态下对象头里到底写什么**。JDK 15+ 默认少走偏向（§8.1.1）；JDK 22+ 轻量与重量形态都可能变（§8.2、§8.2.1）。

**本节只讲 JDK 8～14 经典位布局。** JDK 15+ 的 `markWord.hpp`、JDK 22+ 的轻量锁新实现见 §8。

---

## 5. 经典四阶段：无锁 → 偏向 → 轻量 → 重量

**JDK 8～14 的面试主干。** JDK 15+ 默认跳过偏向（§2）；JDK 22+ 轻量实现又变了（§8）。如果你在读 OpenJDK 17/21 的源码，可以把本节当成 **历史模型 + 对照表**：四阶段叙事仍然常考，但别当成你机器上的唯一路径。

### 5.0 先建立时间线：谁在什么时候推动状态变

下面不是「每次加锁都走满四格」，而是 **常见触发条件**（对象头上具体位模式见 §4）：

| 场景 | 对象头大致怎么走 |
|------|------------------|
| 对象 `new` 出来，还没人进 `synchronized` | **无锁**（`001`） |
| **第一个**线程来加锁，JDK 8 且偏向开着 | 可能 **偏向** 到该线程（`101`），或 CAS **轻量** |
| **同一线程**反复进（已偏向） | 多半检查 Mark Word 是否仍是自己，**不胀** |
| **别的线程**也来抢（已偏向） | **撤销偏向** → 进入 **轻量** CAS 竞争 |
| 轻量 CAS / 自旋仍搞不定，或要 `wait` | **膨胀** 到 **重量**（ObjectMonitor） |
| 线程退出 `synchronized`，无人争用 | 轻量路径可 **恢复置换头** 回无锁（§7）；**不是**重量自动缩回轻量 |

图里箭头表示 **争用变猛时** 对象头 **可能** 怎么跳；解锁、撤销、deflation 各管什么见 §7。

```mermaid
flowchart LR
    无锁态[无锁 001] -->|偏向锁开启| 偏向态[偏向锁 101]
    偏向态 -->|其他线程竞争| 轻量态[轻量级锁 00]
    无锁态 -->|偏向锁关闭| 轻量态
    轻量态 -->|CAS或自旋失败| 重量态[重量级锁 10]
```

> JDK 15+ 默认不走 **偏向锁** 这一档，常见 **无锁 → 轻量 / fast-lock → 重量**（对照 §8.1.1）。

### 5.1 无锁

对象刚创建时，Mark Word 处于 **未锁定（unlocked）** 状态（低位 `01`，biased=0，§4.3 第一行）。

**第一个**线程第一次对该对象执行 `monitorenter` 时：

- **JDK 8 且偏向锁开着**（`-XX:+UseBiasedLocking`，默认）：在满足偏向延迟等条件时，可能直接把对象 **偏向** 到当前线程（§5.2），对象头变成 `101`。
- **否则**（含 JDK 15+ 默认）：跳过偏向，走 **轻量级锁** 的 CAS（§5.3）。

### 5.2 偏向锁

**适用前提**：偏向锁仍开启，且对象已成功偏向到线程 A。

同一线程 A 再次进入 `synchronized` 时，往往只需看 Mark Word 是否仍标记为「偏向 A」（模式 `101`），成本很低——**不必**每次都做轻量锁那套「建锁记录 + CAS 改对象头」。

**别的线程 B** 也来竞争同一把锁时，不能只改回无锁就完事。JVM 要做 **偏向撤销（revoke）**：把对象拉回 **可竞争** 状态，常见是进入 **轻量级锁** 路径，让 A、B 用 CAS / 自旋抢（§5.3）。撤销本身有成本；[JEP 374](https://openjdk.org/jeps/374) 也提到维护复杂，这是 JDK 15 起 **默认关闭偏向** 的原因之一。

### 5.3 轻量级锁

**典型入口**：无锁上第一次 CAS；或偏向被撤销后；或 JDK 15+ 默认从无锁直接到这里。对象头形态见 §4.4。

下面三步是 **JDK 8 经典轻量锁**；JDK 22+ 可能有新实现，但「先栈上试、争用再胀」的直觉还在。

1. 在当前线程栈上建 **锁记录（Lock Record）**，把 **原 Mark Word** 拷进锁记录的 **置换头（displaced header）**。  
2. **CAS** 把对象头改成「指向这条锁记录 + 低位 `00`」。成功则当前线程持有轻量锁。  
3. CAS 失败 → 说明别的线程持有或正在抢 → **自旋** 若干次；仍失败 → **膨胀** 到 `ObjectMonitor`（§5.4）。

临界区很短、争用很少时，全程可能停在轻量；多线程长时间互斥或需要阻塞等待时，会 **胀** 到重量。

### 5.4 重量级锁

**膨胀（inflate）** 之后，对象头（JDK 8 经典布局）指向 **`ObjectMonitor`**（低位 `10`）。此后：

- **阻塞、唤醒**：等待的线程挂在监视器队列上，可能涉及内核调度。
- **`wait` / `notify`**：依赖监视器的 **等待集（wait set）**；栈上的锁记录 **没有** 等待集，所以调用 `wait()` 前对象通常已经胀完成。
- **重入计数**：同一线程多次 `monitorenter` 在 `ObjectMonitor` 上累加，与 JLS 重入语义一致。

膨胀逻辑在 HotSpot 的 `synchronizer.cpp`。**JDK 22+** 若开启 ObjectMonitorTable，对象头里 **不一定** 仍直接存监视器指针（§8），但 **语义仍由 ObjectMonitor 承担**。

---

## 6. 两个代码场景

下面两段代码用来对照 §5 的状态变化，不是性能测试模板。

```java
// 单线程反复进入 — JDK 8 且 -XX:+UseBiasedLocking 时，可能一直停在偏向锁
Object lock = new Object();
for (int i = 0; i < 1_000_000; i++) {
    synchronized (lock) { }
}

// 两线程抢同一把锁 — 偏向撤销 → 轻量 CAS → 可能膨胀
// 仅示意，别在生产抄；看虚拟线程钉住问题就换 Thread.ofVirtual()
Object shared = new Object();
new Thread(() -> {
    for (int i = 0; i < 10_000_000; i++) synchronized (shared) { }
}, "t1").start();
new Thread(() -> {
    for (int i = 0; i < 10_000_000; i++) synchronized (shared) { }
}, "t2").start();
```

### 6.1 单线程循环：可能「一直偏着」

| 步骤 | 发生了什么（JDK 8 + 偏向开着时） |
|------|----------------------------------|
| `new Object()` | `lock` 的 Mark Word：**无锁** `001` |
| 第一次 `synchronized (lock)` | 可能 **偏向** 到当前线程 → `101` |
| 后续 999_999 次 | 同线程再进：检查偏向仍是自己，**通常不胀、也不走完整轻量 CAS** |

JDK 15+ 默认 **没有偏向这一档**，同样代码多半在 **无锁 ↔ fast-lock（`00`）** 之间来回，和 JDK 8 观测不同——对比时看 §2、§8.1.1。

第一个例子看 **「同线程重复进」**；第二个看 **「多线程争用」**（§6.2）。

### 6.2 两线程互抢：撤销 → CAS → 可能胀

| 步骤 | JDK 8（偏向默认开） | JDK 15+（默认无偏向） |
|------|---------------------|------------------------|
| `t1` 先抢到锁 | 可能先 **偏向 t1**（`101`），或 **轻量** | 通常 **无锁 → CAS 轻量/fast-lock**（`00`） |
| `t2` 也来 `synchronized (shared)` | 已偏向 t1 → **撤销** → 轻量 CAS | **无撤销档**；直接与 t1 **CAS / 自旋** 争用 |
| 循环极多次、争用持续 | CAS / 自旋失败 → **胀** 到 ObjectMonitor（`10`） | 同上 |

第二个例子在 JDK 8 上能看到 **撤销**；在 JDK 21 上更能对照 **§8.1.1** 的「无锁直接 CAS 到 `00`」。虚拟线程 **钉住** 见 §9。

---

## 7. 解锁、撤销、监视器收缩：别都叫「降级」

很多人把「解锁」「撤销」「监视器收缩」都叫成降级，其实对应 **三套不同机制**。它们 **不是** 对称的「重量 → 轻量 → 偏向 → 无锁」阶梯。

| 名字 | 谁触发 | 对象头 / 监视器上发生什么 | 常见误解 |
|------|--------|---------------------------|----------|
| **轻量锁解锁** | 线程正常退出 `synchronized`，且无人争用 | CAS 把对象头 **恢复成置换头**，回到 **无锁** 外观 | ❌ 不是「重量锁降回轻量锁」 |
| **偏向锁撤销（revoke）** | **别的线程** 来竞争已偏向的对象 | 撤掉偏向，拉回 **可竞争**（常进轻量 CAS） | ❌ 不是日常 `monitorexit` 触发的「降级」 |
| **监视器收缩（deflation）** | VM 在空闲时回收 **胀出来** 的 `ObjectMonitor` | 监视器实例可能被回收；**JLS 不承诺** 重量锁缩回轻量 | ❌ 不能据此推断「线上会逐级降锁」 |

展开三点：

1. **轻量锁解锁**：只有当前还停在 **轻量路径** 时，才用锁记录里的置换头恢复 Mark Word。若已经 **胀成重量**，解锁走的是 `ObjectMonitor` 逻辑，**不会**沿 §5 流程图箭头倒着变回 `00` 轻量形态。  
2. **偏向锁撤销**：解决的是「对象已经偏心到线程 A，线程 B 也要抢」；和「线程 A 正常出临界区」不是一回事。  
3. **deflation**：实现层优化（`synchronizer.cpp` 等），减轻监视器堆积；**语言语义** 不要求你从重量「降档」回轻量。

JDK 15+ 默认没偏向锁，别指望「用久了会自动偏回去」。

---

## 8. 现代 HotSpot：偏向锁退场与 Mark Word 再变

前面四阶段讲的是 JDK 8 时代的经典模型。线上若是 JDK 15+，默认行为已经不同；JDK 22+ 又引入 Lilliput 相关改动。这一节把 **默认路径** 和 **读源码时该看哪份头文件** 对齐一下。

### 8.1 JDK 15+：偏向锁默认关闭

[JEP 374](https://openjdk.org/jeps/374) 从 JDK 15 起默认关偏向锁，常见路径：**无锁 → fast-lock（快速锁）→ ObjectMonitor**。面试里的「四阶段」仍要会，但 **线上 JDK 17 / 21 默认没有偏向那一格**（§2）。

**JDK 15～21** 的 [`markWord.hpp`](https://github.com/openjdk/jdk/blob/jdk-21/src/hotspot/share/oops/markWord.hpp)（示例标签 jdk-21，别的版本请换标签）用 **3 种 lock 值** 描述普通对象（注释原文，低位在右）：

```text
[header | 00]  locked    fast-locking in use
[header | 01]  unlocked
[header | 10]  monitor   inflated lock
```

读源码：JDK 8 → `markOop.hpp`；JDK 15+ → 对应版本标签的 `markWord.hpp`；**别**用 git 默认分支当「你机器上的实现」。

**JDK 22+** 的轻量锁新实现与 ObjectMonitorTable 见 §8.2；**fast-lock 与 JDK 8 轻量的对照见下一小节 §8.1.1**。

### 8.1.1 对照课：JDK 8「轻量级锁」与 JDK 15～21「fast-lock」

很多人卡在：**名字从 lightweight 改成 fast-lock，到底还是不是 §4 那一套？** 可以分三层记——**语言语义不变、对象头低位模式大体不变、源码文件名与中间缺一档偏向不同**。

#### 第一层：对你写 Java 的人——几乎没差

| 问题 | 答案 |
|------|------|
| `synchronized` 语义变了吗？ | **没有**。仍是监视器、可重入、该胀还是胀。 |
| JDK 21 第一次进 `synchronized` 还会 CAS 抢对象头吗？ | **会**。默认 **不再先偏向**，从无锁直接走 **locked（`00`）** 那条用户态路径。 |
| 还会胀到 `ObjectMonitor` 吗？ | **会**。争用、`wait` 等仍要完整监视器（§5.4）。 |

所以：**把 fast-lock 理解成「JDK 15+ 源码里的轻量锁/fast 路径名字」即可**，不是第三种完全不同的锁。

#### 第二层：对读对象头的人——低位模式对齐 §4

| 对比项 | JDK 8（§4，`markOop.hpp`） | JDK 15～21（`markWord.hpp`，示例 jdk-21） |
|--------|---------------------------|------------------------------------------|
| 无锁 | 低 3 位常记 `001`（lock=`01`, biased=0） | `[header \| 01]` **unlocked** |
| 「轻量」形态 | `[ptr → Lock Record \| 00]`，置换头在栈上（§4.4） | `[header \| 00]` **locked / fast-locking** — **仍是低位 `00`** |
| 重量 | `[ptr → ObjectMonitor \| 10]` | `[header \| 10]` **monitor / inflated** |
| 偏向 | `[thread… \| 1 \| 01]`，默认常开 | **默认关**；参数在 JDK 15+ 弃用/无效（§2） |

**相同直觉（JDK 8 轻量 ≈ JDK 15～21 fast-lock）：**

1. 对象头从 **unlocked** 被 **CAS** 改成 **locked（`00`）**，尽量留在用户态。  
2. 争用加剧或需要完整监视器语义 → **胀成 `10`（monitor）**。  
3. 轻量路径仍依赖 **栈上的锁记录 + 备份旧 Mark Word** 这类思路（JDK 8 叫置换头；JDK 21 源码里在 fast-lock / lightweight 相关路径，具体字段名以你标签下的 `stackLock.hpp`、`lockStack` 等为准）——**不是**对象旁边另挂一个 `int lockLevel`。

**不同点（别硬套 §4 每一位）：**

| 不同点 | 说明 |
|--------|------|
| **没有默认偏向档** | §4 的 `101`、§5.2 的「同线程只检查不 CAS」在 JDK 15+ **默认路径上不存在**；读 jdk-21 时别先找 biased 位域当主线。 |
| **头文件与类型名** | `markOop` → `markWord`；读锁逻辑跟 `synchronizer.cpp`、`lockStack` 等，而不是只盯 JDK 8 的 `markOop.cpp` 命名。 |
| **`header` 里具体塞什么** | jdk-21 注释写 `[header | 00]`，**header 位域布局**与 JDK 8 图里的 `ptr to Lock Record` 不一定逐位相同；**以你版本 `markWord.hpp` 为准**，只保证 **低 2 位 lock 值** 与 §4 的 `00/01/10` 对齐。 |
| **≠ JDK 22 新轻量锁** | §8.1 讲的是 **15～21 的 fast-lock**；JDK 22+ Lilliput **又换了一套** 轻量实现（§8.2），**不能**说「fast-lock = 全版本轻量锁终局」。 |

#### 第三层：对追一次加锁路径的人——JDK 21 上怎么走（对照 §5.0）

下面用 **JDK 21、默认参数、普通对象、两线程 eventually 争用** 串一遍（省略 JIT 锁消除等）：

```text
  new Object()
       │
       ▼
  Mark Word: unlocked [ … | 01 ]          ← 对应 §4 无锁，但没有「先偏向」
       │
       │  线程 A：第一次 monitorenter
       ▼
  CAS → locked [ header | 00 ]            ← fast-locking（≈ §5.3 轻量）
       │     栈：Lock Record + 备份旧 header
       │
       │  线程 B：也来 monitorenter（争用）
       ▼
  自旋 / CAS 失败 …
       │
       ▼
  inflate → monitor [ header | 10 ]       ← ObjectMonitor（§5.4）
```

和 **JDK 8 + 偏向开着** 的差别只在中间：**JDK 8 可能多一格「偏向 A，A 再进只检查」**；**JDK 21 默认从 unlocked 直接 CAS 到 locked（`00`）**。一旦到了 **`10`**，后面阻塞、`wait`、重入计数的故事与 §5.4 一致。

#### 小结（背一句就够）

> **JDK 15～21 的 fast-lock：源码新名字 + 默认无偏向；对象头仍是 `01` 无锁、`00` 用户态抢锁、`10` 监视器；语义与 JDK 8 轻量锁同族，位图细节看对应标签的 `markWord.hpp`，别和 JDK 22 新实现混谈。**


### 8.2 JDK 22+：轻量锁新实现与 ObjectMonitorTable

**JDK 22+** 在 Lilliput 下有两条独立改动，别混成一条：

| 改动 | 影响什么 | 和 §4 的关系 |
|------|----------|--------------|
| [轻量锁新实现](https://wiki.openjdk.org/display/lilliput/Lightweight+Locking) | 用户态加锁路径（`00` 档）的栈锁、对象头编码 | **≠** JDK 8 §4.4 / **≠** §8.1.1 的 fast-lock 细节 |
| [ObjectMonitorTable](https://wiki.openjdk.org/display/lilliput/Synchronization+Using+The+ObjectMonitorTable) | **胀完成后** 监视器与对象头的关联方式 | **≠** §4.3 第四行「对象头直接存 Monitor 指针」 |

**UseObjectMonitorTable** 是否默认开启、轻量锁新实现是否已启用，都以你版本标签下的 `markWord.hpp` 与发行说明为准。

### 8.2.1 对照课：§4「重量指针在对象头」vs ObjectMonitorTable

§4.3 / §4.4 教的是 JDK 8：**胀完之后，Mark Word 低位 `10`，高位是指向 `ObjectMonitor` 的指针**——对象头「贴着」监视器。

ObjectMonitorTable 要解决的问题是：**监视器仍然由 `ObjectMonitor` 实现（阻塞队列、`wait`、重入计数不变），但对象头不必再塞进一整根 monitor 指针**，改为：

```text
  JDK 8 经典（§4.3 第四行）              JDK 22+ 旁路表（概念图）

  对象.markWord                         对象.markWord
  [ ptr ──────────► ObjectMonitor |10 ]   [ 少量锁状态位 | 10? … ]
                           │                    │
                           │                    └──► 旁路表 ──► ObjectMonitor
                           │                         （按对象地址查）
                           ▼
                    等待集、阻塞队列仍在 Monitor 里
```

| 对比 | JDK 8 重量（§4） | ObjectMonitorTable（JDK 22+，开启时） |
|------|------------------|--------------------------------------|
| **语言语义** | `synchronized` / `wait` 不变 | 不变 |
| **胀之后谁管阻塞** | `ObjectMonitor` | 仍是 `ObjectMonitor` |
| **对象头上能看到什么** | 往往是 **monitor 指针 + `10`** | **未必**还能读到完整指针；查表关联 |
| **读源码** | `markOop.hpp` + `synchronizer.cpp` | 对应标签 `markWord.hpp` + Lilliput Wiki |

**和 §8.1.1 的分工：** §8.1.1 对齐的是 **`01` 无锁 ↔ `00` 用户态锁**（fast-lock ≈ 轻量）；§8.2.1 对齐的是 **`10` 胀完成之后对象头还贴不贴 monitor 指针**。JDK 22+ 可能 **两处都变**，所以要分开读。

不同开关下「对象头里到底存什么」必须以运行版本为准。背一句：

> **胀完的语义还在 ObjectMonitor；JDK 8 把指针写在对象头上，JDK 22+ 可能改存法 + 旁路表——别用 §4 第四行硬解线上 JDK 22 的对象头 dump。**

---

## 9. 虚拟线程：synchronized 与钉住（pinning）

### 9.1 载体、挂载、卸载（先分清三个词）

虚拟线程见 [JEP 444](https://openjdk.org/jeps/444)。读钉住前先分清：

| 概念 | 是什么 |
|------|--------|
| **虚拟线程** | 轻量线程，由 JVM 调度，数量可以很多 |
| **载体线程（carrier）** | 实际跑字节码的 **平台线程**；某一时刻一个载体上 **挂载** 一条虚拟线程 |
| **卸载（unmount）** | 虚拟线程在 I/O 等 **阻塞点** 上让出载体，载体去跑别的虚拟线程 |

理想情况：阻塞时 **卸载** → 载体不空转。问题出在 **`synchronized` 与监视器的绑定** 上。

### 9.2 钉住（pinning）是什么

```text
  JDK 21～23 典型问题（块内发生阻塞时）

  虚拟线程 VT ──挂载──► 载体平台线程 C
       │                      │
       │  在 synchronized 内   │  VT 阻塞（I/O、wait、等锁…）
       │  需要持有监视器       │  往往无法卸载 VT
       └──────────────────────┴──► C 被钉住，无法服务其他 VT
```

在 **JDK 21～23**，虚拟线程 **进入并持有** `synchronized` 时，监视器与 **平台线程** 的绑定过紧。只要在块内发生 **阻塞**（I/O、`Object.wait`、等锁），往往 **无法卸载**，载体被 **钉住（pin）**，平台线程池的伸缩性就会变差。临界区极短、纯 CPU、几乎无争用时，问题不一定暴露，但也不能据此认为 `synchronized` 对虚拟线程「永远无害」。

**JDK 24** 的 [JEP 491](https://openjdk.org/jeps/491) 针对 **阻塞在监视器上** 的场景改进了卸载，载体更容易被释放。即便如此，**也不是所有代码路径都不会钉住**；排查时仍应查看 JFR 的 pinned 相关事件。

**和 §5 的关系：** 钉住讨论的是 **虚拟线程调度**，不是 Mark Word 四阶段；但块内若因争用 **胀到 ObjectMonitor 并阻塞**，更容易触发载体占用问题。

---

## 10. 相邻机制与实践

读完全文后，别把下面几条和 Mark Word 四阶段 **混成一条线**：

| 机制 | 发生在哪一层 | 和 synchronized 分级锁的关系 |
|------|--------------|------------------------------|
| **`ReentrantLock`（AQS）** | `java.util.concurrent` 自己的队列与状态 | **不经过** 对象头 Mark Word 分级 |
| **锁消除（lock elimination）** | JIT 编译期 | 证明锁不会被别的线程访问时 **删掉** 加锁；与运行时膨胀无关 |
| **锁粗化（lock coarsening）** | JIT 编译期 | 把相邻多次加锁 **合并** 成一次；也不改变某次真的抢锁时的 Mark Word 路径 |
| **运行时膨胀 / deflation** | HotSpot `synchronizer` | 本文主线：`synchronized` + Mark Word → ObjectMonitor |

线上遇到锁相关性能问题时，应先用 JFR 或 async-profiler 看 **真实争用与阻塞**，再决定是否调整锁粒度或换用 `ReentrantLock`。别凭「偏向锁应该更快」之类 **JDK 8 印象** 去调已废弃的参数（§2、§8）。

---

## 11. 读者自检

先 **不看上文** 答 7 题。5 题以上答得上，主线就清楚了；卡住的回 § 对应段或 §12。

1. **版本对号入座**：线上 **JDK 21**，默认锁路径哪几段？面试里的「偏向锁」还算现代默认吗？（§2、§8.1）

2. **一次加锁**：线程第一次对空闲对象进 `synchronized`，Mark Word 大致怎样？争用加剧往哪走？（§4、§5）

3. **三个易混词**：轻量锁 **解锁**、偏向锁 **撤销**、监视器 **收缩（deflation）** 各是什么？能说「重量锁降回轻量锁」吗？（§7）

4. **为什么胀**：`Object.wait()` 为啥不能停在「只有栈上锁记录」？（§5.4）

5. **虚拟线程**：JDK 21 和 JDK 24，虚拟线程在 `synchronized` 里 **阻塞** 时，载体钉住行为差在哪？（§9）

6. **fast-lock 对照**：JDK 21 第一次 `monitorenter` 还会先偏向吗？`00/01/10` 与 §4 怎么对应？（§8.1.1）

7. **ObjectMonitorTable**：JDK 22+ 胀完后，对象头一定还存 monitor 指针吗？和 §4 重量行差在哪？（§8.2.1）

**参考答案（先自答再展开）**

<details>
<summary>点击展开</summary>

1. JDK 21：**无偏向**（偏向锁参数无效），常见 **无锁 → 轻量 / 快速锁 → ObjectMonitor**（跳过偏向锁这一档）。偏向锁是 JDK 8 叙事和面试题，**不是** JDK 21 默认。

2. **一次加锁**  
   - **JDK 21**：`01` 无锁 → CAS 到 `00`（fast-lock）→ 争用可胀到 `10`。  
   - **JDK 8 且开偏向**：可能先 `101` 偏向；争用时撤销 → 轻量 CAS → 胀。  
   （§4、§5、§8.1.1）

3. **解锁**：轻量路径恢复置换头，回无锁。**撤销**：竞争撤偏向，回可竞争态（常进轻量锁）。**收缩**：VM 回收空闲 ObjectMonitor，**语言无承诺**从重量缩回轻量。不能说「重量降回轻量」。

4. `wait`/`notify` 要 **等待集**；锁记录只有轻量加锁，没有等待集，得先胀。

5. **JDK 21～23**：块内 **阻塞** 时载体易 **钉住**，难卸载。**JDK 24（JEP 491）**：阻塞在监视器上卸载改善，载体好释放，但 **并非所有路径** 都不会钉住。

6. **不会**先偏向。unlocked=`01` → CAS 到 locked=`00`（fast-lock，≈§4 轻量）→ 争用可胀到 monitor=`10`；与 §4 对齐的是 **低 2 位 lock 值**（§8.1.1）。

7. **不一定**。JDK 8 重量行是对象头 **直接存 monitor 指针**；JDK 22+ 开启旁路表时，可能经 **ObjectMonitorTable** 关联监视器；**语义仍在 ObjectMonitor**（§8.2.1）。

</details>

---

## 12. 延伸阅读

- [JLS §17.1](https://docs.oracle.com/javase/specs/jls/se17/html/jls-17.html#jls-17.1) — 语言语义 ⭐
- [JEP 374](https://openjdk.org/jeps/374) — 偏向锁默认关闭 ⭐
- [JEP 444](https://openjdk.org/jeps/444) — 虚拟线程与钉住（pinning）背景 ⭐
- [JEP 491](https://openjdk.org/jeps/491) — JDK 24 虚拟线程 + synchronized ⭐
- [轻量锁新实现（Wiki）](https://wiki.openjdk.org/display/lilliput/Lightweight+Locking) — JDK 22+
- [ObjectMonitorTable（Wiki）](https://wiki.openjdk.org/display/lilliput/Synchronization+Using+The+ObjectMonitorTable) — Mark Word 与监视器旁路表 ⭐
- [markOop.hpp（JDK 8u）](https://github.com/openjdk/jdk8u/blob/master/hotspot/src/share/vm/oops/markOop.hpp) — 经典四阶段位布局
- [markWord.hpp（jdk-21 标签）](https://github.com/openjdk/jdk/blob/jdk-21/src/hotspot/share/oops/markWord.hpp) — JDK 21 LTS 示例；其他版本换标签
- [synchronizer.cpp](https://github.com/openjdk/jdk/blob/jdk-21/src/hotspot/share/runtime/synchronizer.cpp) — 膨胀 / 收缩（inflate / deflation）
