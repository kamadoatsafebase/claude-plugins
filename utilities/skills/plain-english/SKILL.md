---
name: plain-english
description: Rewrite text so it reads human, concise, and simple. Removes AI writing patterns, then applies ASD-STE100 Simplified Technical English. Use when the user types /plain-english, or asks to simplify, tighten, de-jargon, or de-AI a piece of prose. Args are optional, and default to the most recent text in the conversation.
---

# /plain-english

Rewrite text to read human, concise, and simple.

Usage: `/plain-english [text | file path | description of the text]`

- No args: use the most recent text the user wrote, pasted, or asked about.
- A file path: rewrite that file in place.
- Anything else: treat it as the text itself, or as a hint about which text to rewrite. Use your best judgment. Do not ask for clarification.

---

## Step 1 — Remove the AI writing patterns

Read `references/ai-patterns.md` and apply it to the resolved text. Take the result as your working draft.

Keep these two constraints through every later step:

- **Keep every claim.** The structure can change. The information cannot disappear.
- **Invent no facts.** Add no new name, number, date, quote, or citation.

## Step 2 — Apply ASD-STE100

Read `references/asd-ste100.md` and apply it to the draft.

## Step 3 — Verify

Check the rewrite against each item. Fix the problems, check once more, then stop.

1. Every claim from the source is still there. Nothing is invented.
2. No sentence is longer than the cap for its text type.
3. No paragraph has more than six sentences or more than one topic.
4. No compound noun has more than three words.
5. No passive voice has a known actor.
6. No semicolons. No Latin abbreviations. No phrasal verbs that one verb can replace.
7. Read it aloud. If a sentence still stumbles, rewrite the paragraph around its main point.

## Step 4 — Return the result

- **File mode:** write only the final text to the file. Then give a summary of three lines maximum.
- **Pasted or inline text:** print the final rewrite. Then list what changed, in five bullets maximum.
- **Called by another skill or task:** return the final text only.
