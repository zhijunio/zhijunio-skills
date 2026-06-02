# English prose: strip the AI register

## Quick pass (before editing)

1. **Meaning first**: if you delete evaluative filler, does the claim still stand? If not, keep the claim, lose the tone.
2. **Do not compress paragraphs**: remove AI tells; do **not** turn explanatory prose into outline stubs. Split overloaded sentences; do not merge distinct steps into one terse line.
3. **Prefer verbs and nouns** over abstract nouns (*utilization* → *use*, *leverage* → *use* / *apply*).
4. **One idea per sentence** when a sentence is muddy — not «one sentence per entire subsection.»

## High-frequency AI tells (cut or rewrite)

- Openers: *It is important to note*, *It goes without saying*, *In today's world*, *Let's dive in*, *Let's unpack*
- Hedges piled up: *may potentially*, *could arguably*, *somewhat significantly*, *fairly unique*
- False engagement: *I'd be happy to help*, *Great question!*, *Absolutely!* (unless chat context truly needs it)
- Template transitions: *Moreover*, *Furthermore*, *Additionally* three times in a row with thin content
- Signalling depth: *delve*, *deep dive*, *holistic*, *synergy*, *paradigm*, *leverage*, *circle back*, *moving forward*

## Replacement table (L1 scan — prefer these over bans)

Search the draft for each pattern; replace in place. Do not add new facts.

| Avoid (AI tell) | Prefer |
|-----------------|--------|
| It is important to note / It goes without saying | (delete) or lead with the fact |
| In today's world / In the age of | Start with the specific event or problem |
| Let's dive in / Let's unpack | (delete) or «Here is how X works» |
| Moreover / Furthermore / Additionally (×3 thin) | Vary openings; use the real subject |
| delve / leverage / holistic / synergy / paradigm | use / apply / overall / (delete) |
| This means that / What this means is | So / Therefore |
| In conclusion / To summarize | One concrete closing sentence, or delete |
| may potentially / could arguably | may / might / (delete hedge stack) |
| significantly improve / robust solution | name the metric or mechanism if already in draft |

Layered QA: [`write-qa-layers.md`](write-qa-layers.md).

## Mechanical patterns

- **Rule of three** with parallel adjectives (*fast, scalable, and secure*) with no evidence → keep one concrete trait or add none.
- **Every paragraph starts with *Additionally*** → vary openings; use the real subject.
- **Passive stacks** (*It should be noted that X was done*) → *We did X* or *X happened* when agent is clear.

## Audience

| Audience | Tone |
|----------|------|
| Blog / newsletter | Conversational; contractions OK if the source already uses them |
| RFC / design doc | Precise; avoid motivational filler |
| Support / status update | Short; lead with outcome, then context |

## One-line check

Would a fluent editor keep this paragraph, or reach for the red pen for *voice*, not *grammar*? If voice, keep cutting filler.
