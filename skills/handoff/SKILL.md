---
name: handoff
description: >
  Grava o savepoint da sessão: escreve/sobrescreve o HANDOFF.md na raiz do repositório
  com o estado atual do trabalho, para a próxima sessão retomar exatamente de onde parou.
  Use quando o usuário pedir "handoff", "salvar onde paramos", "savepoint", "fim de sessão",
  ou antes de encerrar um trabalho longo. Também é a estrutura de referência quando o hook
  de compactação pedir atualização do HANDOFF.md.
---

# /handoff — gravar o savepoint da sessão

Você vai escrever (sobrescrever) o arquivo `HANDOFF.md` na **raiz do repositório git
atual**. Ele é o handoff vivo entre sessões: a próxima sessão (sua ou de outra pessoa)
deve conseguir retomar o trabalho lendo só este arquivo.

## Passos

1. Colete o estado real — não invente:
   ```bash
   git rev-parse --show-toplevel   # raiz do repo (onde o arquivo vai)
   git log --oneline -8            # o que foi commitado recentemente
   git status --short              # o que ficou sem commitar
   ```
2. Combine com o contexto da conversa: o que foi feito, decidido, testado e adiado.
3. Escreva o `HANDOFF.md` seguindo o template abaixo, em PT-BR, conciso e factual.
4. Se o repositório versiona documentação (convenção do projeto), ofereça commitar.

## Template

```markdown
# HANDOFF — onde paramos

> Última sessão: **DD/MM/AAAA**. Leia isto ao reabrir o terminal.

## O que foi entregue nesta sessão
- [entregas com hash de commit quando houver, ex: `abc1234`]
- [inclua o que foi TESTADO e como; se algo não foi testado, diga explicitamente]

## Estado atual
- [branch, tree limpo ou não, serviços rodando, migrações aplicadas]
- [comandos de checagem rápida que provam que está tudo no ar]

## Próximos passos (em ordem de prioridade)
1. [o mais importante primeiro; inclua contexto suficiente para começar sem perguntar]
2. [...]

## Armadilhas conhecidas (não tropeçar de novo)
- [gotchas descobertos na sessão: o erro, a causa e como evitar]

## Decisões tomadas (e porquês)
- [decisões de arquitetura/escopo desta sessão com a justificativa em 1 linha]

---
*Handoff vivo — sobrescrito a cada fim de sessão e a cada compactação (plugin savepoint).*
```

## Regras

- **Sobrescreva** o arquivo inteiro — handoff velho é pior que nenhum (induz a erro).
- **Fatos, não intenções**: "testado no browser com dados reais" só se aconteceu.
- Priorize o que a próxima sessão precisa **decidir ou fazer**, não o histórico completo
  (histórico é papel do CHANGELOG/git log).
- Se não estiver em um repositório git, pergunte ao usuário onde salvar antes de escrever.
- Máximo ~80 linhas. Se passar disso, você está escrevendo changelog, não handoff.
