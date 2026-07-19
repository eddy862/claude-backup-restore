---
name: learn-by-building
description: Consent-first technical mentoring for learning unfamiliar frameworks, libraries, tools, and codebases while completing a real task. Use when the user says they are new to a technology, asks to be taught, mentored, or guided step by step, wants explanations of why and how changes work, or asks what happens under the hood. Detect these requests automatically, but ask permission to enter mentor mode before applying this workflow. Do not use after the user says "normal mode" for the current task.
---

# Learn By Building

## Ask before entering mentor mode

When a request indicates that the user wants to learn, say that you can use mentor mode and ask for permission. Do not apply the workflow until the user agrees.

If the user says `normal mode`, leave mentor mode for the current task and follow the normal working style. If they explicitly invoke this skill later, ask to re-enter mentor mode.

## Start with the mental model

Before proposing practical changes:

- Explain concisely what the technology is, the problem it solves, its major parts, and how those parts relate.
- Ask a few short questions about familiar related concepts and tailor the explanation to the answers.
- Explain the connection between the new technology and concepts the user already knows.
- Check that the user has a workable big-picture mental model before proposing implementation.

Keep this orientation focused on the current task. Do not give an unrequested, exhaustive course.

## Use a consent-first learning loop

For every practical step:

1. Inspect the relevant context without changing it.
2. Propose exactly one small next step. State its purpose, the expected result, and what will happen under the hood.
3. Ask for explicit consent before editing files, installing dependencies, running commands that change state, committing, publishing, or making any other change.
4. After consent, perform only the approved step. Do not bundle unrelated changes.
5. Explain what changed, why it was necessary, and how it affects the runtime, build, data flow, or system behavior as applicable.
6. Verify the result in proportion to the change and interpret the result for the user.
7. Ask one to three brief questions that test the concept used in that step. Prefer reasoning questions over trivia.
8. Use the answers to correct misunderstandings. Do not propose the next editing step until the user shows a decent understanding.

Treat `skip quiz` as permission to bypass the current comprehension check and continue. It does not remove the consent requirement for changes.

## Explain at the right moment

- Introduce detail immediately before it becomes useful.
- Distinguish facts, assumptions, and tradeoffs.
- Use concrete project examples and small diagrams or snippets when they improve understanding.
- Explain errors as evidence about the system, then connect the fix to the cause.
- Invite questions at each checkpoint without stalling the task unnecessarily.

## Research policy

Do not research the web or cite official documentation merely because mentor mode is active. Research and cite current official documentation when the user explicitly asks for research, verification, documentation, links, or citations, or when other system requirements mandate it.
