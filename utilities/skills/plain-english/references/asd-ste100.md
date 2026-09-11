# ASD-STE100

Reference: <https://www.asd-ste100.org/>, Issue 9. Fetch the PDF only if a specific rule is in doubt.

Use the dictionary as a **substitution list, not a closed vocabulary**.

## Classify the text first

| Type | What it is | Sentence cap | Mood |
| --- | --- | --- | --- |
| Procedural | steps, instructions, runbooks, commands | 20 words | imperative ("Remove the cover.") |
| Descriptive | everything else: docs, summaries, messages, prose | 25 words | indicative, never imperative |

Both types: one topic per paragraph, six sentences maximum.

## Words

- Use one term per thing, every time. Never use two names for one item.
- Replace a nominalization with the verb inside it: "gives an indication of" → "shows".
- Use no slang, jargon, or regional idiom.
- Use no phrasal verb when one verb exists: "put out" → "extinguish".
- Use no Latin abbreviation: `e.g.` → "for example", `i.e.` → "that is", `etc.` → "and so on".
- Use gender-neutral language.
- Use three words maximum in a compound noun. Unpack the rest with a preposition: "engine transmission housing attachment bolts" → "the bolts that attach the transmission housing to the engine".

## Sentences

- Use the active voice. Use the passive only when the actor is unknown.
- Put one idea in each sentence. At the cap, split the sentence. Do not trim words out.
- Use simple tenses: "has adjusted" → "adjusted".
- Use no semicolons. Write two sentences.
- Keep the conjunction "that".
- Replace "this" with its referent when more than one thing can be meant.
- Turn a complex sentence into a vertical list.
- Give the condition first, then the action: "If the valve is closed, open it."

## Safety and risk

Give the command or the condition first, then the consequence. Never do the opposite.

## Substitutions

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

## Do not over-apply

Skip these rules unless the text is a technical procedure.

- Allow `-ing` forms.
- Allow contractions in conversational or informal text.
- Follow the house spelling, not American-only spelling.
- Let headings, labels, and UI strings drop articles.
- Allow synonyms outside reference documentation.

Change prose only. Leave code, code blocks, identifiers, quoted material, YAML, JSON, link targets, and command output unchanged.
