---
name: handoff
description: >
  Grava o savepoint da sessão: escreve/sobrescreve o arquivo de handoff da branch atual
  (HANDOFF.md na main; HANDOFF-<branch>.md nas demais) com o estado do trabalho, para a
  próxima sessão — desta ou de QUALQUER outra ferramenta de IA — retomar exatamente de
  onde parou. Use quando o usuário pedir "handoff", "salvar onde paramos", "savepoint",
  "fim de sessão", ou antes de encerrar um trabalho longo. Também é a estrutura de
  referência quando o hook de compactação pedir atualização do handoff.
---

# /handoff — gravar o savepoint da sessão

Você vai escrever (sobrescrever) o **arquivo de handoff da branch atual** na raiz do
repositório git. Ele é o handoff vivo entre sessões: a próxima sessão (sua, de outra
pessoa, ou de outra ferramenta — Cursor, Windsurf, qualquer agente) deve conseguir
retomar o trabalho lendo só este arquivo.

## Qual arquivo escrever (regra de branch)

```bash
git rev-parse --show-toplevel            # raiz do repo (onde o arquivo vai)
git rev-parse --abbrev-ref HEAD         # branch atual
```

- Branch `main` ou `master` → `HANDOFF.md`
- Qualquer outra branch → `HANDOFF-<branch>.md`, com `/` trocado por `-`
  (ex: branch `feat/filtros` → `HANDOFF-feat-filtros.md`)

Assim cada linha de trabalho tem seu próprio savepoint, sem conflito entre branches.

## Passos

1. Colete o estado real — não invente:
   ```bash
   git log --oneline -8            # o que foi commitado recentemente
   git status --short              # o que ficou sem commitar
   ```
2. Combine com o contexto da conversa e aplique o **filtro do que vale lembrar**
   (seção abaixo).
3. Escreva o arquivo seguindo o template, em PT-BR (ou no idioma do projeto),
   conciso e factual — **incluindo o frontmatter YAML**, que é o que outras
   ferramentas leem por máquina.
4. Se o repositório versiona documentação (convenção do projeto), ofereça commitar.

## O filtro do que vale lembrar

Handoff não é diário. Antes de escrever cada item, aplique o teste: **"a próxima
sessão faria algo diferente por saber disso?"** Se não, corte.

ENTRA:
- Decisões com consequência ("escolhemos X em vez de Y porque Z")
- Correções não óbvias ("a API retorna null onde o tipo diz string")
- Estado que não está no git (serviço parado, migration pendente, token expirando)
- Próximos passos com o contexto mínimo para começar sem perguntar
- Preferências que o usuário declarou ("sem lib nova", "commits em inglês")

NÃO ENTRA:
- Narrativa do que aconteceu passo a passo (isso é o git log)
- O que já está em CHANGELOG, README ou no próprio código
- Elogios, hesitações, tentativas descartadas sem lição
- Qualquer coisa que o leitor descobriria em 10 segundos de `git log`

## Template

```markdown
---
savepoint: 1
updated: 2026-07-09T15:30:00-03:00
branch: main
tool: claude-code
status: in-progress   # in-progress | done | blocked
next: "uma linha: o próximo passo mais importante"
---

# HANDOFF — onde paramos

## O que foi entregue nesta sessão
- [entregas com hash de commit quando houver, ex: `abc1234`]
- [inclua o que foi TESTADO e como; se algo não foi testado, diga explicitamente]

## Estado atual
- [branch, tree limpo ou não, serviços rodando, migrações aplicadas]
- [comandos de checagem rápida que provam que está tudo no ar]

## Próximos passos (em ordem de prioridade)
1. [o mais importante primeiro; contexto suficiente para começar sem perguntar]
2. [...]

## Armadilhas conhecidas (não tropeçar de novo)
- [gotchas descobertos: o erro, a causa e como evitar]

## Decisões tomadas (e porquês)
- [decisões de arquitetura/escopo desta sessão com a justificativa em 1 linha]

---
*Handoff vivo — sobrescrito a cada fim de sessão e a cada compactação (plugin savepoint).*
```

### Semântica do frontmatter (protocolo savepoint v1)

| Campo | Significado |
|---|---|
| `savepoint` | Versão do protocolo (sempre `1` por ora) — permite evolução sem quebrar leitores |
| `updated` | ISO-8601 com timezone — leitores decidem se o handoff está fresco ou velho |
| `branch` | Branch em que o handoff foi gravado |
| `tool` | Quem gravou: `claude-code`, `cursor`, `windsurf`, `human`, ... |
| `status` | `in-progress` (tem trabalho pendente), `done` (ciclo fechado), `blocked` (aguardando algo externo) |
| `next` | Uma linha com o próximo passo — o mínimo que qualquer agente precisa para agir |

## Regras

- **Sobrescreva** o arquivo inteiro — handoff velho é pior que nenhum (induz a erro).
- **Fatos, não intenções**: "testado no browser com dados reais" só se aconteceu.
- Priorize o que a próxima sessão precisa **decidir ou fazer**, não o histórico
  (histórico é papel do CHANGELOG/git log).
- Se não estiver em um repositório git, pergunte ao usuário onde salvar antes de escrever.
- Máximo ~80 linhas além do frontmatter. Passou disso, você está escrevendo changelog.
