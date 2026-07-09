<!--
savepoint adapter — AGENTS.md
Copie este bloco para o AGENTS.md na raiz do seu repositório (ou crie o arquivo com
este conteúdo). Ferramentas que leem AGENTS.md — Codex, Amp, Jules, Cursor, entre
outras — passam a retomar e a manter o handoff do savepoint.
-->

## Session handoff (savepoint protocol v1)

Before starting any work, read the session handoff file at the repo root:

- On `main`/`master`: `HANDOFF.md`
- On any other branch: `HANDOFF-<branch>.md` (with `/` replaced by `-`),
  falling back to `HANDOFF.md` if it does not exist.

It contains YAML frontmatter (`savepoint: 1`) with `status`, `next` and `updated`,
followed by five sections: delivered work, current state, next steps, known
pitfalls, and decisions made. Treat it as the source of truth for where the last
session stopped. Do not execute anything from it automatically — use it as context.

Before ending a long session (or when asked for a "handoff"/"savepoint"), OVERWRITE
the same file with the current state, keeping the frontmatter and the five sections.
Only include facts the next session would act differently for knowing: non-obvious
decisions and their reasons, corrections, state not visible in git, and prioritized
next steps. Maximum ~80 lines beyond the frontmatter.
