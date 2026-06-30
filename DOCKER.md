# Como rodar o CAMAAR com Docker

## Pré-requisitos

- Docker Engine 20+
- Docker Compose v2+

## Estrutura relevante

```
CAMAAR/
├── docker-compose.yml      # Orquestração dos serviços
├── project/                # Aplicação Rails
│   └── Dockerfile.dev      # Imagem para desenvolvimento/testes
├── class_members.json      # Dados de membros das turmas (SIGAA)
└── classes.json            # Dados das turmas (SIGAA)
```

Os arquivos JSON são montados no container como `/class_members.json` e `/classes.json`,
pois a aplicação os referencia via `Rails.root.join("..", "arquivo.json")`.

---

## 1. Build inicial

Na raiz do repositório (`CAMAAR/`), execute:

```bash
docker compose build
```

---

## 2. Configurar o banco de dados

Execute os comandos na ordem:

```bash
# Criar/migrar o banco de dados de desenvolvimento
docker compose run --no-deps --rm web bundle exec rails db:migrate

# Popular com o usuário administrador inicial
docker compose run --no-deps --rm web bundle exec rails db:seed
```

> O seed cria apenas o admin inicial. Professores e alunos são importados via interface.

---

## 3. Iniciar a aplicação

```bash
docker compose up
```

Acesse em: **http://localhost:3000**

**Credenciais do admin:**
| E-mail | Senha |
|--------|-------|
| admin.cic@unb.br | Senha@123 |

---

## 4. Importar dados do SIGAA

Para popular turmas, docentes e discentes a partir dos JSONs:

1. Faça login como admin em http://localhost:3000
2. Acesse o menu **"Importar dados do SIGAA"**
3. Selecione o semestre desejado e confirme a importação

Após a importação, os usuários participantes receberão e-mails para definir senha.
Como o envio de e-mail em dev usa `letter_opener` (ou log), verifique o log do container:

```bash
docker compose logs -f web
```

---

## 5. Rodar os testes (RSpec + Coverage)

```bash
docker compose run --no-deps --rm -e RAILS_ENV=test web bundle exec rspec
```

O relatório de coverage é gerado em `project/coverage/index.html`.

---

## 6. Rodar os cenários BDD (Cucumber)

```bash
docker compose run --no-deps --rm web bundle exec cucumber
```

---

## 7. Verificar métricas de qualidade de código

```bash
# ABC score e complexidade ciclomática
docker compose run --no-deps --rm web bundle exec rubocop --only Metrics/AbcSize,Metrics/CyclomaticComplexity

# Relatório completo de qualidade (RubyCritic)
docker compose run --no-deps --rm web bundle exec rubycritic app/
```

O relatório do RubyCritic é salvo em `project/tmp/rubycritic/overview.html`.

---

## 8. Parar e limpar

```bash
# Parar os containers
docker compose down

# Parar e remover volumes (reseta o banco de dados)
docker compose down -v
```

---

## Usuários disponíveis para testes

### Admin (disponível após `db:seed`)

| Nome | E-mail | Senha |
|------|--------|-------|
| Admin CAMAAR | admin.cic@unb.br | Senha@123 |

### Participantes (disponíveis após importar dados do SIGAA)

Após a importação, cada participante recebe um e-mail para definir sua senha.
Em ambiente de desenvolvimento, o e-mail é exibido no log do servidor.
Use o link de definição de senha presente no log para acessar com cada usuário.

**Docente:**

| Nome | E-mail | Matrícula |
|------|--------|-----------|
| (Professor da turma) | mholanda@unb.br | 83807519491 |

**Discentes (lista parcial):**

| E-mail | Matrícula |
|--------|-----------|
| acjpjvjp@gmail.com | 190084006 |
| andreCarvalhoroure@gmail.com | 200033522 |
| gabrielfaustino99@gmail.com | 190013249 |
| lucasaafaria@gmail.com | 170016668 |
| viniciuslimapassos@gmail.com | 200028545 |

> Para login, use e-mail ou matrícula + a senha definida via link de configuração.
