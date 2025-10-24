Backend Rails — Biblioteca Digital (API)

Este repositório contém a infraestrutura e a implementação de uma API Rails para o desafio de Biblioteca Digital.

Pré‑requisitos
- Docker Desktop instalado e em execução.

Bootstrap (gerar app Rails)
- Windows (PowerShell): `./scripts/generate_rails.ps1`
- Linux/macOS (Bash): `bash scripts/generate_rails.sh`

Isso cria o app em `./api`, ajusta o `database.yml` (env vars), adiciona gems (JWT, bcrypt, kaminari, RSpec, GraphQL) e habilita CORS. Em seguida, instala as dependências via `bundle` em container.

Subir a stack (API + Postgres)
- `docker compose up --build`
- API em: `http://localhost:3000`

Banco de dados
- Postgres exposto em `localhost:5432` (`postgres`/`postgres`). DB padrão: `app_development`.

Endpoints principais (REST)
- Autenticação
  - `POST /api/signup` body: `{ "user": {"email":"a@b.com","password":"secret123","password_confirmation":"secret123"} }`
  - `POST /api/login` body: `{ "email":"a@b.com", "password":"secret123" }` → `{ token }`
- Autores
  - `POST /api/authors` headers: `Authorization: Bearer <token>`
    - Pessoa: `{ "author": {"type":"PersonAuthor","name":"Nome","birth_date":"1990-01-01"} }`
    - Instituição: `{ "author": {"type":"InstitutionAuthor","name":"Org","city":"Recife"} }`
  - `GET /api/authors`
- Materiais
  - `GET /api/materials?q=texto&page=1&per=20` → retorna publicados; se autenticado, inclui seus materiais (qualquer status)
  - `GET /api/materials/:id` → permite ver rascunho/arquivado somente para o criador
  - `POST /api/materials` headers: `Authorization: Bearer <token>`
    - Livro: `{ "material": {"type":"Book","title":"...","status":"rascunho|publicado|arquivado","author_id":1,"isbn":"9780140328721","page_count":96} }`
      - Se `isbn` informado e `title/page_count` ausentes, tenta preencher via OpenLibrary.
    - Artigo: `{ "material": {"type":"Article","title":"...","doi":"10.1000/xyz123","status":"publicado","author_id":1} }`
    - Vídeo: `{ "material": {"type":"Video","title":"...","duration_minutes":10,"status":"rascunho","author_id":1} }`
  - `PUT/PATCH /api/materials/:id` e `DELETE /api/materials/:id` → apenas o criador

GraphQL (diferencial)
- `POST /graphql` body: `{ "query": "{ materials { id title status author { name } } }" }`
- Em desenvolvimento: GraphiQL em `http://localhost:3000/graphiql`

Validações principais
- User: email obrigatório/único/formato; senha mínimo 6
- Material: título 3..100, status em `rascunho|publicado|arquivado`, descrição até 1000, autor e usuário obrigatórios
- Livro: `isbn` 13 dígitos e único; `page_count` > 0
- Artigo: `doi` único e formato `10.xxxx/...`
- Vídeo: `duration_minutes` inteiro > 0

Testes
- Rodar: `docker compose exec api bundle exec rspec`

Observação
- Se o Docker não estiver rodando, os scripts avisam para iniciar o Docker Desktop.
