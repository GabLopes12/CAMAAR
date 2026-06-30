# Relatório de Qualidade — Sprint 3

## 1. Cobertura de Código (RSpec / SimpleCov)

| Arquivo | Coverage antes | Coverage depois | Mudanças realizadas |
|---------|---------------|-----------------|---------------------|
| `app/controllers/course_classes_controller.rb` | 0.00% | 100% | Criado `spec/requests/course_classes_spec.rb` com testes de index (listagem por departamento) e show (acesso negado para turmas de outro departamento) |
| `app/jobs/application_job.rb` | 0.00% | 100% | Criado `spec/jobs/application_job_spec.rb` verificando herança de `ActiveJob::Base` |
| `app/helpers/formularios_helper.rb` | 55.56% | 100% | Criado `spec/helpers/formularios_helper_spec.rb` cobrindo todos os branches: boolean (Sim/Não/—), rating (valor/—) e text (valor/—) |
| `app/controllers/password_resets_controller.rb` | 86.67% | 100% | Adicionados testes para: senha incompatível com confirmação, exibição do formulário edit com token válido |
| `app/controllers/sessions_controller.rb` | 89.47% | 100% | Adicionado teste para ação `destroy` (logout) |
| `app/controllers/templates_controller.rb` | 90.41% | 100% | Adicionados testes para: ação `show`, botão `+` (add_questao) durante edição |
| `app/controllers/formularios_controller.rb` | 93.88% | 100% | Adicionados testes para: ação `new` e `show` para usuário não-admin |
| `spec/spec_helper.rb` | — | — | Corrigido: tinha conteúdo não-Ruby colado que causava SyntaxError na linha 19 |
| **Total geral** | **92.74%** | **99.14%** | — |

---

## 2. ABC Score (Metrics/AbcSize)

| Arquivo / Método | ABC score antes | ABC score depois | Mudanças realizadas |
|-----------------|----------------|-----------------|---------------------|
| `sessions_controller.rb#create` | 20.78 | ≤15 | Extraídos `handle_pending_setup`, `handle_login_success`, `handle_login_failure` |
| `password_resets_controller.rb#update` | 15.56 | ≤15 | Extraídos `passwords_match?`, `render_password_mismatch`, `apply_password_reset` |
| `resposta_controller.rb#create` | 20.83 | ≤15 | Extraídos `carregar_formulario_e_respostas`, `redirect_para_formulario_com_alerta`, `salvar_respostas` |
| `formularios_controller.rb#create` | 20.71 | ≤15 | Extraídos `render_create_success`, `render_create_failure` |
| `formularios_controller.rb#exportar_csv` | 17.83 | ≤15 | Extraídos `gerar_csv`, `cabecalho_csv`, `linha_csv` |
| `formularios_controller.rb#formularios_pendentes_para` | 16.43 | ≤15 | Extraído `papel_por_turma` |
| `templates_controller.rb#create` | 20.83 | ≤15 | Extraído `salvar_novo_template` |
| `templates_controller.rb#update` | 32.26 | ≤15 | Extraídos `processar_atualizacao_template`, `atualizar_template`, `persistir_questao` |
| `class_members_importer.rb#call` | 19.85 | ≤15 | Extraído `process_member` |
| `class_members_importer.rb#department_for` | 16.16 | ≤15 | Extraído `resolve_department_code` |
| `class_members_importer.rb#sync_user` | 27.44 | ≤15 | Extraídos `create_user`, `apply_user_updates`, `build_user_updates` |
| `classes_importer.rb#call` | 17.72 | ≤15 | Extraídos `find_course_class`, `sync_course_class` |
| `classes_importer.rb#department_for` | 16.16 | ≤15 | Extraído `resolve_department_code` |
| `data_synchronizer.rb#call` | 20.42 | ≤15 | Extraído `build_result` |
| `db/migrate/20260615000300_create_users.rb#change` | 16.03 | desabilitado | Adicionado `rubocop:disable Metrics/AbcSize` — migration não pode ser refatorada sem risco |

**Resultado:** `rubocop --only Metrics/AbcSize` — 0 ofensas detectadas.
**RubyCritic score:** 92.13

---

## 3. Complexidade Ciclomática (Metrics/CyclomaticComplexity)

| Arquivo / Método | Complexidade antes | Complexidade depois | Mudanças realizadas |
|-----------------|-------------------|-------------------|---------------------|
| `class_members_importer.rb#department_for` | 8 | ≤7 | Extração de `resolve_department_code` eliminou a cadeia de `\|\|` com safe navigation do método principal |
| `class_members_importer.rb#sync_user` | 9 | ≤7 | Extração de `create_user`, `apply_user_updates` e `build_user_updates` distribuiu os branches condicionais |
| `classes_importer.rb#department_for` | 8 | ≤7 | Extração de `resolve_department_code` (mesmo padrão do importer acima) |

**Resultado:** `rubocop --only Metrics/CyclomaticComplexity` — 0 ofensas detectadas.

> Nota: a redução de complexidade ciclomática foi obtida como consequência direta da refatoração do ABC score — os mesmos métodos eram fonte de ambos os problemas.

---

## 4. Usuários disponíveis para testes

### Admin (disponível após `rails db:seed`)

| Nome | E-mail | Senha | Papel |
|------|--------|-------|-------|
| Admin CAMAAR | admin.cic@unb.br | Senha@123 | Administrador |

### Participantes (disponíveis após importar dados do SIGAA pela interface)

Após a importação, cada participante recebe um e-mail com link de definição de senha.
Em ambiente de desenvolvimento, o link aparece no log do servidor.

**Docente:**

| E-mail | Matrícula | Papel |
|--------|-----------|-------|
| mholanda@unb.br | 83807519491 | Docente |

**Discentes (seleção):**

| E-mail | Matrícula | Papel |
|--------|-----------|-------|
| acjpjvjp@gmail.com | 190084006 | Discente |
| andreCarvalhoroure@gmail.com | 200033522 | Discente |
| gabrielfaustino99@gmail.com | 190013249 | Discente |
| lucasaafaria@gmail.com | 170016668 | Discente |
| viniciuslimapassos@gmail.com | 200028545 | Discente |

> Para login utilize e-mail **ou** matrícula + a senha definida via link de configuração de conta.
> O sistema envia e-mails de setup apenas uma vez por usuário novo.
