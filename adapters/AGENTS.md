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

Before writing the handoff, move history out of it: if the repo has `CHANGELOG.md`
or `docs/CHANGELOG.md`, append ONE entry per feature that shipped in this session
(deploy date, what the user can now do, migrations, commits). Append only — never
rewrite existing entries. If the repo has a docs check (`scripts/placar-docs.sh` or
`npm run docs:check`), run it and set `docs: ok` or `docs: pending` in the
frontmatter, with `docs_pending` listing each debt (new endpoints without a line in
the API reference, changed screens without a manual page). Never write the user
manual from the handoff; only record the debt.
