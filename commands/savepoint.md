---
description: Grava o savepoint da sessão (HANDOFF.md da branch atual) para retomar depois
---

# /savepoint — gravar o savepoint da sessão

Este comando é um atalho para a skill `handoff` do plugin savepoint. Ao ser
invocado, execute a skill `savepoint:handoff` seguindo exatamente as instruções
dela: escreva (sobrescreva) o arquivo de handoff da branch atual na raiz do
repositório git.

Regra de arquivo:
- Branch `main`/`master` → `HANDOFF.md`
- Outras branches → `HANDOFF-<branch>.md` (com `/` trocado por `-`)

Passos:
1. Colete o estado real (não invente): `git log --oneline -8` e `git status --short`.
2. Combine com o contexto da conversa e aplique o filtro "a próxima sessão faria
   algo diferente por saber disso?" — corte o que não passar.
3. Escreva o arquivo com o frontmatter YAML do protocolo savepoint v1 e o template
   da skill `handoff` (O que foi entregue / Estado atual / Próximos passos /
   Armadilhas / Decisões), em PT-BR, conciso, máximo ~80 linhas.
4. Sobrescreva o arquivo inteiro. Se o repo versiona docs, ofereça commitar.

Se não estiver num repositório git, pergunte ao usuário onde salvar antes de escrever.
