# Modelo de domínio

Não há mais models separados para `Admin`/`Professor`/`Aluno`: existe um único
`User`, diferenciado por papel (`role`) global e por papel dentro de cada turma
(`ClassMembership#role`).

## User
Pessoa que acessa o sistema — administrador ou participante (docente/discente).

- `name`, `email` (único, normalizado em minúsculas), `registration`/matrícula (única)
- `role`: enum `admin` / `participant` — define se vê o painel administrativo
- `password_digest` (via `has_secure_password`), tokens com TTL para definição
  (`PASSWORD_SETUP_TTL` = 7 dias) e redefinição (`PASSWORD_RESET_TTL` = 2 horas) de senha
- `belongs_to :department` (opcional)
- `has_many :class_memberships` → `has_many :course_classes, through: :class_memberships`
- Como admin: `has_many :templates` e `has_many :formularios` (`foreign_key: :admin_id`)

## Department
Departamento ao qual turmas e usuários pertencem.

- `name`, `code` (único)
- `has_many :course_classes`, `has_many :users`

## CourseClass (Turma)
- `code`, `class_code`, `semester` (únicos em conjunto)
- `belongs_to :department`
- `has_many :class_memberships` → `has_many :users, through: :class_memberships`
- `has_many :formularios`

## ClassMembership (vínculo Usuário ↔ Turma)
Substitui o antigo `TurmaAluno`; cobre tanto discentes quanto docentes da turma.

- `belongs_to :user`, `belongs_to :course_class`
- `role`: enum `discente` / `docente`
- Único por `(user_id, course_class_id, role)`

## Template
Modelo de formulário reutilizável criado por um admin.

- `title`, `target_role` (para quem o formulário gerado a partir dele se destina)
- `belongs_to :admin, class_name: "User"`
- `has_many :questaos, dependent: :destroy`
- `has_many :formularios, dependent: :nullify` (apagar o template não apaga formulários já gerados)

## Formulario
Instância de avaliação gerada a partir de um `Template` para uma `CourseClass`.

- `title`, `status` (padrão `"draft"`)
- `belongs_to :template` (opcional — pode ficar nulo se o template for excluído)
- `belongs_to :course_class` (opcional)
- `belongs_to :admin, class_name: "User"`
- `has_many :questaos, dependent: :destroy` — questões **clonadas** do template no
  momento da criação (ver `app/services/formularios/create_from_template.rb`), para que
  edições futuras no template não afetem formulários já gerados

## Questao
Pertence a um `Template` **ou** a um `Formulario` (nunca ambos) — a clonagem ao gerar
o formulário cria uma cópia independente da questão.

- `enunciado`, `tipo` (`rating` / `text` / `boolean`)
- `belongs_to :template, optional: true`
- `belongs_to :formulario, optional: true`
- `has_many :respostas`

## Submissao
Registro de que um usuário respondeu a um formulário.

- `belongs_to :formulario`, `belongs_to :user`

## Respostum (Resposta)
Resposta individual a uma questão dentro de uma submissão.

- `belongs_to :submissao`, `belongs_to :questao`

## ImportInconsistency
Registro de inconsistência encontrada durante a importação de dados do SIGAA
(ver `app/services/sigaa/`).

- `source`, `message`
