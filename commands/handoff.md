---
description: Grava o savepoint da sessão (HANDOFF.md da branch atual) para retomar depois
---

# /handoff — gravar o savepoint da sessão

Este comando é um atalho para a skill `handoff` do plugin savepoint. Ao ser
invocado, execute a skill `savepoint:handoff` seguindo exatamente as instruções
dela: escreva (sobrescreva) o arquivo de handoff da branch atual na raiz do
repositório git.

Regra de arquivo:
- Branch `main`/`master` → `HANDOFF.md`
- Outras branches → `HANDOFF-<branch>.md` (com `/` trocado por `-`)

Passos:
1. Colete o estado real (não invente): `git log --oneline -8` e `git status --short`.
2. Descarregue o histórico: se o repo tem `CHANGELOG.md` ou `docs/CHANGELOG.md`,
   acrescente UMA entrada por frente que foi para produção nesta sessão (data de
   deploy, o que o usuário passa a fazer, migrations, commits). Só acrescenta —
   nunca reescreve o que existe. Endpoint novo ganha linha na referência de API
   do projeto (`docs/endpoints.md` ou equivalente), se ela existir.
3. Combine com o contexto da conversa e aplique o filtro "a próxima sessão faria
   algo diferente por saber disso?" — corte o que não passar.
4. Rode o gate de docs se existir (`bash scripts/placar-docs.sh`, senão
   `npm run docs:check`). Limpo → `docs: ok`; senão `docs: pending` +
   `docs_pending` com uma linha por dívida (inclua toda tela/rótulo que mudou e
   não tem página no manual). O manual em si NÃO é escrito aqui.
5. Escreva o arquivo com o frontmatter YAML do protocolo savepoint v1 e o template
   da skill `handoff` (O que foi entregue / Estado atual / Próximos passos /
   Armadilhas / Decisões), em PT-BR, conciso, máximo ~80 linhas.
6. Sobrescreva o arquivo inteiro. Se o repo versiona docs, ofereça commitar
   (handoff + changelog + endpoints juntos).

Se não estiver num repositório git, pergunte ao usuário onde salvar antes de escrever.
