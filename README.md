# savepoint

**Morreu? Volta do savepoint, não do início.**

Plugin do Claude Code que elimina o "onde é que a gente parou?": mantém um
`HANDOFF.md` vivo na raiz de cada repositório, atualizado automaticamente nos
momentos em que o contexto se perde — e recarregado quando você volta.

## O que ele faz

| Momento | O que acontece |
|---|---|
| **Conversa vai compactar** (PreCompact) | O resumo da compactação é instruído a preservar decisões, próximos passos e armadilhas — nasce com formato de handoff |
| **Conversa compactou** (PostCompact) | O Claude atualiza o `HANDOFF.md` na raiz do repo antes de retomar a tarefa, com o contexto ainda fresco |
| **Sessão abre** (SessionStart) | Se existir `HANDOFF.md` no diretório, o conteúdo é injetado no contexto — o Claude já começa sabendo onde a última sessão parou |
| **Você pede** (`/savepoint:handoff`) | Grava o savepoint manualmente com estrutura completa (entregas, estado, próximos passos, armadilhas, decisões) |

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

## O formato do HANDOFF.md

Cinco seções, máximo ~80 linhas, sempre sobrescrito (handoff velho é pior que nenhum):

1. **O que foi entregue** — com hashes de commit e o que foi de fato testado
2. **Estado atual** — serviços, branch, comandos de checagem rápida
3. **Próximos passos** — em ordem de prioridade, com contexto para começar sem perguntar
4. **Armadilhas conhecidas** — os gotchas da sessão, para não tropeçar duas vezes
5. **Decisões tomadas** — com o porquê em uma linha

O template completo vive em [`skills/handoff/SKILL.md`](skills/handoff/SKILL.md).

## Por que hooks e não instrução no CLAUDE.md?

Instrução em CLAUDE.md depende de o modelo lembrar na hora certa — e ele não sabe
quando a compactação vai acontecer (você também não). Hooks são disparados pelo
próprio Claude Code no evento exato. É a diferença entre "por favor lembre" e
"acontece sempre".

## Requisitos

- Claude Code com suporte a plugins
- `jq` no PATH (usado pelo hook de SessionStart; macOS: `brew install jq`)

## Licença

MIT
