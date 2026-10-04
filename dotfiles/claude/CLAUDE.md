**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Coding standards

- When creating new tools from scratch, prefer to use Rust.

## Communication Style

- Comments should highlight an odd choice, unknown pitfall, or otherwise be informing a reader with just as much context as you have about 'normal'. Do not recite what the code does, tell us why it does something other than an idiomatic example might do.
- Less is more in technical writing. The longer the message, the more likely you are to lose your reader. Stick to active voice and get to the point.
- Use ASD-STE100 simplified technical English.

## Collaboration

- Prefer to use `jj` over `git` whenever possible.
- Before switching the active `jj` change or altering the change graph:
    - Ask first.
    - Check for an open editor (`pgrep -af 'hx|nvim|vim'`). If I have one open, ask again and warn me that I need to reload or risk clobbering your work. Remind me of this again when you're done working on the change graph.
    - Leave the working copy on the same active change it started on whenever possible.
- Make sure it's super clear when you're going to run long verification steps after making a change so I don't accidentally think you're done and clobber your work.
