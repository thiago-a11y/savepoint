# savepoint

**Morreu? Volta do savepoint, não do início.**

Plugin do Claude Code que elimina o "onde é que a gente parou?": mantém um arquivo
de handoff vivo na raiz de cada repositório, atualizado automaticamente nos momentos
em que o contexto se perde — e recarregado quando você volta. E como o handoff segue
um **protocolo aberto em Markdown**, qualquer outra ferramenta (Cursor, Windsurf,
Codex) consegue ler e manter o mesmo arquivo.

## O que ele faz

| Momento | O que acontece |
|---|---|
| **Conversa vai compactar** (PreCompact) | O resumo da compactação é instruído a preservar decisões, próximos passos e armadilhas — nasce com formato de handoff |
| **Conversa compactou** (PostCompact) | O Claude atualiza o handoff da branch atual antes de retomar a tarefa, com o contexto ainda fresco |
| **Sessão abre** (SessionStart) | Se existe handoff no repo, o conteúdo é injetado no contexto — o Claude já começa sabendo onde a última sessão parou |
| **Você pede** (`/savepoint` ou `/handoff`) | Grava o savepoint com a estrutura completa. Antes, **descarrega o histórico no CHANGELOG** do projeto (uma entrada por frente entregue; endpoint novo ganha linha na referência de API) e **roda o gate de docs** (`scripts/placar-docs.sh` ou `npm run docs:check`), gravando `docs: ok` ou `docs: pending` + lista no frontmatter. O manual de usuário nunca é escrito pelo savepoint — só a dívida fica registrada |

## Instalar

```bash
claude marketplace add thiago-a11y/savepoint
claude plugin install savepoint@savepoint
```

Ou declarativamente no `~/.claude/settings.json`:

```json
{
  "enabledPlugins": { "savepoint@savepoint": true },
  "extraKnownMarketplaces": {
    "savepoint": { "source": { "source": "github", "repo": "thiago-a11y/savepoint" } }
  }
}
```

Abra uma sessão nova do Claude Code e pronto — vale para todos os projetos.

## Exemplo real

Um `HANDOFF.md` gravado ao fim de uma sessão de trabalho (encurtado):

```markdown
---
savepoint: 1
updated: 2026-07-09T10:57:00-03:00
branch: main
tool: claude-code
status: in-progress
next: "Decidir push dos commits locais; depois reconstruir pytest dos routers"
---

# HANDOFF — onde paramos

## O que foi entregue nesta sessão
- Filtros de busca/data/tipo nas 7 telas de listagem (`c9fceae`..`cd9e37a`),
  testados no browser com dados reais
- Fix crítico: abas de pipeline zeradas — a API do CRM só entrega pipeline_id,
  nome resolvido via mapa id→nome (`861ad97`)

## Estado atual
- Tree limpo, tudo commitado (local — push pendente de decisão)
- Checagem rápida: `curl -s -o /dev/null -w "%{http_code}" localhost:8000/docs` → 200

## Próximos passos (em ordem de prioridade)
1. Decidir push para o GitHub (6 commits locais)
2. Reconstruir suíte pytest dos dashboard routers (fixtures pré-multi-tenant)

## Armadilhas conhecidas (não tropeçar de novo)
- asyncpg NÃO aceita string de data — sempre objetos date/datetime (2 bugs por isso)
- API externa: validar payload cru com curl antes de mapear campos

## Decisões tomadas (e porquês)
- Filtragem server-side com {items, total} — o padrão anterior (500 registros
  em memória) mentia na paginação
```

Na sessão seguinte, isso é injetado automaticamente no contexto. Zero re-explicação.

## O protocolo (savepoint v1)

O handoff é Markdown com frontmatter YAML — legível por humanos, parseável por máquinas:

| Campo | Significado |
|---|---|
| `savepoint: 1` | Versão do protocolo — evolui sem quebrar leitores |
| `updated` | ISO-8601 — o leitor decide se está fresco ou velho |
| `branch` | Branch em que foi gravado |
| `tool` | Quem gravou: `claude-code`, `cursor`, `windsurf`, `human`... |
| `status` | `in-progress` \| `done` \| `blocked` |
| `next` | Uma linha: o próximo passo — o mínimo para qualquer agente agir |
| `docs` | *(opcional, 0.3.0)* `ok` \| `pending` — a documentação viva acompanhou o que foi entregue? |
| `docs_pending` | *(opcional)* Lista do que ficou devendo em docs (endpoints sem linha, tela sem página no manual) |

Corpo em cinco seções fixas: **entregue**, **estado atual**, **próximos passos**,
**armadilhas**, **decisões**. Máximo ~80 linhas — handoff não é changelog.

### Branch-aware

Cada linha de trabalho tem seu próprio savepoint:

- `main`/`master` → `HANDOFF.md`
- Outras branches → `HANDOFF-<branch>.md` (`/` vira `-`; fallback para `HANDOFF.md`)

### Multi-máquina e time: de graça, via git

O handoff é um arquivo commitado. `git push` numa máquina, `git pull` na outra —
o savepoint viaja com o repo, para qualquer pessoa do time, sem servidor, sem SaaS,
sem sync proprietário. E o `git log HANDOFF.md` é a história auditável de como o
contexto evoluiu, sessão a sessão.

## Handoff entre ferramentas diferentes

O mesmo arquivo pode ser lido e mantido por outros agentes — os adaptadores em
[`adapters/`](adapters/) ensinam cada ferramenta a falar o protocolo:

| Ferramenta | Como instalar |
|---|---|
| Codex, Amp, Jules e leitores de `AGENTS.md` | Copie o bloco de [`adapters/AGENTS.md`](adapters/AGENTS.md) para o `AGENTS.md` do seu repo |
| Cursor | `mkdir -p .cursor/rules && cp adapters/cursor-savepoint.mdc .cursor/rules/savepoint.mdc` |
| Windsurf | Mesmo conteúdo em `.windsurf/rules/savepoint.md` |

Fluxo real: encerra no Claude Code → abre no Cursor → o Cursor lê o handoff e
continua — e grava o dele ao terminar. Sessão vira estado compartilhado entre
agentes, não memória proprietária de uma ferramenta.

## O filtro do que vale lembrar

A skill aplica um teste em cada item antes de escrever: **"a próxima sessão faria
algo diferente por saber disso?"** Entra: decisões com consequência, correções não
óbvias, estado invisível ao git, próximos passos com contexto. Não entra: narrativa
(isso é o git log), o que já está em outros docs, tentativas sem lição.

## Por que hooks e não instrução no CLAUDE.md?

Instrução em CLAUDE.md depende de o modelo lembrar na hora certa — e ele não sabe
quando a compactação vai acontecer (você também não). Hooks são disparados pelo
próprio Claude Code no evento exato. É a diferença entre "por favor lembre" e
"acontece sempre".

## Requisitos

- Claude Code com suporte a plugins
- `jq` no PATH (macOS: `brew install jq`) — sem ele, o hook de SessionStart
  silencia em vez de quebrar

## Licença

MIT
