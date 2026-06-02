# Research-oriented fetch — sources and failures

Use in **research-write Phase 1** with **`fetch-content`**. General fetch flow → [`fetch-methods.md`](fetch-methods.md).

## 1. Preferred primary sources (technical)

| Domain | Examples |
|--------|----------|
| Java / JVM | [openjdk.org/jeps](https://openjdk.org/jeps/), JLS/JVMS, `raw.githubusercontent.com/openjdk/jdk/**` |
| Specs | IETF RFC, W3C, vendor official docs |
| Code | GitHub **tag** matching release, not only default branch |
| Papers | PDF via `fetch-url.sh` or author-hosted |

**OpenJDK source URLs:** prefer paths under a **release tag** (`jdk-21.0.2`) when explaining production; use **main** only for “upcoming / in development” with that caveat.

## 2. GitHub raw paths

```bash
bash fetch-content/scripts/fetch-url.sh \
  "https://raw.githubusercontent.com/openjdk/jdk/jdk-21/src/java.base/java/lang/String.java"
```

Replace repo, tag, and path with the **release tag and file** relevant to the topic.

## 3. When fetch fails

| Symptom | Next step |
|---------|-----------|
| 404 on blog | Try alternate URL, archive, or official mirror |
| Empty body | Next hop in `fetch-chain.md`; then `mcp-first.md` |
| Paywall | Do not save wall as content; ask user for paste or creds |
| Firecrawl unavailable | `fetch-url.sh` only; note method in `source-index.md` |

**Never** fabricate article or source text.

## 4. Record for research-write

Each fetch → file under `research-write/drafts/<slug>/sources/` + row in `source-index.md` (see **`research-write/references/collect-phase.md`**).

## 5. Anti-patterns

| Do not | Do instead |
|--------|------------|
| Cite SEO roundup as primary | JEP / spec / source file |
| Say “current master proves…” | JDK version + tagged path |
| Re-fetch same URL every session | Move saved file into `sources/` |
