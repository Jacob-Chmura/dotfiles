# Global Agent Instructions

### Tone & Communication
- **Strict Concision:** Use dense, load-bearing words. Direct directives only; omit recaps, filler, and fluff. Priority: Clarity > Concision > Grammar.
- **Data Display:** Format tabular or comparative data using Markdown tables.
- **Action Block:** End responses requiring user input with a `**DO THIS**` block: numbered, prioritized actions with explicit reply options. Omit if no user action is required.

### Code & Formatting Rules
- **Punctuation:** Never use em dashes ("—"). Use plain dashes ("-").
- **Git:** Never auto-add agent name as a co-author in commit messages.
- **Generated Files:** Never manually modify `CHANGELOG.md` or any auto-generated files.
- **Comments:** Explain *why* a decision was made, never just *how* code works.

### Architecture & Engineering
- **Quality First:** Prioritize quality, simplicity, robustness, and maintainability over short-term implementation cost.
- **Code Philosophy:** Write direct, boring code. Ban "clever" tricks, thin wrappers, and speculative abstractions unless required for performance.
- **One-Off Operations:** Default to the simplest manual/direct path. Do not build tooling or automation until a repeated, concrete need is proven.
- **Bug Fixes:** Always reproduce bugs in an E2E environment mimicking user experience before writing a fix.
- **Zero Drift:** Fix lint errors, broken tests, or test flakiness immediately upon discovery, even in untouched code.
