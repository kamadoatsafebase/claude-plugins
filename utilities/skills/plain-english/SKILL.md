---
name: plain-english
description: Rewrite text so it reads human, concise, and simple — run the humanizer skill, then apply ASD-STE100 Simplified Technical English. Use when the user types /plain-english, or asks to simplify, tighten, de-jargon, or de-AI a piece of prose. Args are optional — defaults to the most recent text in the conversation.
---

# /plain-english

Rewrite text to read human, concise, and simple: `humanizer` first, then ASD-STE100.

Usage: `/plain-english [text | file path | description of the text]`

- No args: use the most recent text the user wrote, pasted, or asked about in this conversation.
- A file path: rewrite that file in place.
- Anything else: treat it as the text itself, or as a hint about which text to rewrite. Use your best judgment — don't ask for clarification.

> **Prerequisite:** the `humanizer` plugin (`blader/humanizer`). If the `humanizer:humanizer` skill is unavailable, say so in one line and run Steps 2, 4, and 5 only.

---

## Step 1 — Run humanizer

Invoke `humanizer:humanizer` via the Skill tool in **embedded mode**, passing the resolved text. Take its final rewrite as your working draft.

That skill owns the AI-pattern catalogue. Do not restate, re-derive, or second-guess its rules here.

Carry its two hard constraints through every later step:

- **Keep every claim.** Structure may change; information may not disappear.
- **Invent no facts.** No new name, number, date, quote, or citation.

## Step 2 — Classify the text

ASD-STE100 gives conflicting rules for the two text types, so decide first:

| Type | What it is | Sentence cap | Mood |
| --- | --- | --- | --- |
| Procedural | steps, instructions, runbooks, commands | 20 words | imperative ("Remove the cover.") |
| Descriptive | everything else — docs, summaries, messages, prose | 25 words | indicative; no imperative |

Both types: one topic per paragraph, six sentences maximum.

## Step 3 — Apply ASD-STE100

Source: <https://www.asd-ste100.org/> — Issue 9 (2025-01-15), 53 writing rules plus a controlled dictionary, maintained by the ASD STEMG. Free; the downloads page has the PDF. Fetch it only if a specific rule is in doubt.

Use the dictionary as a **substitution list, not a closed vocabulary** — its 875 approved words are sized for maintenance manuals and will flatten ordinary prose.

**Words**

- One term per thing, every time. Never two names for one item.
- Replace a nominalization with the verb inside it: "gives an indication of" → "shows".
- No slang, jargon, or regional idiom.
- No phrasal verbs when one verb exists: "put out" → "extinguish".
- No Latin abbreviations: `e.g.` → "for example", `i.e.` → "that is", `etc.` → "and so on".
- Gender-neutral language.
- Maximum three words in a compound noun. Unpack the rest with a preposition: "engine transmission housing attachment bolts" → "the bolts that attach the transmission housing to the engine".

**Sentences**

- Active voice. Passive only when the actor is genuinely unknown.
- One idea per sentence. Split at the sentence cap from Step 2 rather than trimming words out.
- Simple tenses. "has adjusted" → "adjusted".
- No semicolons. Use two sentences.
- Keep the conjunction "that" — it marks where the main clause ends.
- Replace "this" with its referent when more than one thing could be meant.
- Turn a complex sentence into a vertical list.
- State the condition first, then the action: "If the valve is closed, open it."

**Safety and risk**

Lead with the command or the condition, then the consequence — never the reverse.

**Substitutions**

| Replace | With | Replace | With |
| --- | --- | --- | --- |
| utilize | use | prior to | before |
| assist, facilitate | help | subsequent to | after |
| perform, conduct, execute | do | due to | because of |
| ensure, verify, ascertain | make sure | via | through |
| provide | give | however | but |
| obtain, achieve | get | therefore | thus |
| commence, initiate | start | additional | more |
| terminate | stop | various | different |
| indicate, reveal | show | appropriate | applicable |
| determine, locate | find | critical | very important |
| modify, alter | change | exceed | more than |
| inform, advise | tell | approximately-class | about |

## Step 4 — Do not over-apply

These ASD-STE100 rules are aerospace-specific. Skip them unless the text is a technical procedure:

- The ban on `-ing` forms — "Before starting the server" is fine.
- The ban on contractions — wrong for conversational or informal text.
- American-only spelling — follow the house style instead.
- The article-before-every-noun rule — headings, labels, and UI strings drop articles legitimately.
- The synonym ban — correct for reference docs, monotonous in narrative.

Leave untouched: code, code blocks, identifiers, quoted material, YAML or JSON, link targets, and command output. Change prose only.

## Step 5 — Verify

Check the rewrite against each item. Fix and re-check once, then stop.

1. Every claim from the source survives; nothing was invented.
2. No sentence is over the Step 2 cap.
3. No paragraph is over six sentences or covers two topics.
4. No compound noun is over three words.
5. No passive voice with a known actor.
6. No semicolons, no Latin abbreviations, no phrasal verbs with a one-word equivalent.
7. Read it aloud. If a sentence still stumbles, rewrite the paragraph around its main point.

## Step 6 — Return the result

- **File mode** — write only the final text to the file, then give a summary of at most three lines.
- **Pasted or inline text** — print the final rewrite, then list what changed, in at most five bullets.
- **Called by another skill or task** — return the final text only.
