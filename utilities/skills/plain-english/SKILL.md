---
name: plain-english
description: Rewrite text so it reads human, concise, and simple. Runs the humanizer skill, then applies ASD-STE100 Simplified Technical English. Use when the user types /plain-english, or asks to simplify, tighten, de-jargon, or de-AI a piece of prose. Args are optional, and default to the most recent text in the conversation.
---

# /plain-english

Rewrite text to read human, concise, and simple. Run `humanizer` first, then ASD-STE100.

Usage: `/plain-english [text | file path | description of the text]`

- No args: use the most recent text the user wrote, pasted, or asked about.
- A file path: rewrite that file in place.
- Anything else: treat it as the text itself, or as a hint about which text to rewrite. Use your best judgment. Do not ask for clarification.

> **Prerequisite:** the `humanizer` plugin (`blader/humanizer`). If the `humanizer:humanizer` skill is not available, say so in one line. Then run Steps 2, 4, and 5 only.

---

## Step 1 — Run humanizer

Pass the resolved text to `humanizer:humanizer` through the Skill tool in embedded mode. Take its final rewrite as your working draft.

That skill owns the AI-pattern catalogue. Do not restate, re-derive, or second-guess its rules here.

Carry its two hard constraints through every later step:

- **Keep every claim.** The structure can change. The information cannot disappear.
- **Invent no facts.** Add no new name, number, date, quote, or citation.

## Step 2 — Classify the text

ASD-STE100 gives conflicting rules for the two text types, so decide first.

| Type | What it is | Sentence cap | Mood |
| --- | --- | --- | --- |
| Procedural | steps, instructions, runbooks, commands | 20 words | imperative ("Remove the cover.") |
| Descriptive | everything else: docs, summaries, messages, prose | 25 words | indicative, never imperative |

Both types: one topic per paragraph, six sentences maximum.

## Step 3 — Apply ASD-STE100

Source: <https://www.asd-ste100.org/>. Issue 9 (2025-01-15) has 53 writing rules and a controlled dictionary, and the ASD STEMG maintains it. The standard is free, and the downloads page has the PDF. Fetch the PDF only if a specific rule is in doubt.

Use the dictionary as a **substitution list, not a closed vocabulary**. Its 875 approved words are sized for maintenance manuals, and they flatten ordinary prose.

**Words**

- Use one term per thing, every time. Never use two names for one item.
- Replace a nominalization with the verb inside it: "gives an indication of" → "shows".
- Use no slang, jargon, or regional idiom.
- Use no phrasal verb when one verb exists: "put out" → "extinguish".
- Use no Latin abbreviation: `e.g.` → "for example", `i.e.` → "that is", `etc.` → "and so on".
- Use gender-neutral language.
- Use three words maximum in a compound noun. Unpack the rest with a preposition: "engine transmission housing attachment bolts" → "the bolts that attach the transmission housing to the engine".

**Sentences**

- Use the active voice. Use the passive only when the actor is unknown.
- Put one idea in each sentence. At the cap from Step 2, split the sentence. Do not trim words out.
- Use simple tenses: "has adjusted" → "adjusted".
- Use no semicolons. Write two sentences.
- Keep the conjunction "that". It shows where the main clause ends.
- Replace "this" with its referent when more than one thing can be meant.
- Turn a complex sentence into a vertical list.
- Give the condition first, then the action: "If the valve is closed, open it."

**Safety and risk**

Give the command or the condition first, then the consequence. Never do the opposite.

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

These ASD-STE100 rules apply to aerospace only. Skip them unless the text is a technical procedure.

- The ban on `-ing` forms. "Before starting the server" is correct English.
- The ban on contractions. It is wrong for conversational or informal text.
- American-only spelling. Follow the house style.
- The article-before-every-noun rule. Headings, labels, and UI strings drop articles correctly.
- The synonym ban. It is correct for reference docs and monotonous in narrative.

Change prose only. Leave code, code blocks, identifiers, quoted material, YAML, JSON, link targets, and command output unchanged.

## Step 5 — Verify

Check the rewrite against each item. Fix the problems, check once more, then stop.

1. Every claim from the source is still there. Nothing is invented.
2. No sentence is longer than the cap from Step 2.
3. No paragraph has more than six sentences or more than one topic.
4. No compound noun has more than three words.
5. No passive voice has a known actor.
6. No semicolons. No Latin abbreviations. No phrasal verbs that one verb can replace.
7. Read it aloud. If a sentence still stumbles, rewrite the paragraph around its main point.

## Step 6 — Return the result

- **File mode:** write only the final text to the file. Then give a summary of three lines maximum.
- **Pasted or inline text:** print the final rewrite. Then list what changed, in five bullets maximum.
- **Called by another skill or task:** return the final text only.
