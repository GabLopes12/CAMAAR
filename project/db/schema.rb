# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_14_234457) do
  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "departamento_id", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["departamento_id"], name: "index_admins_on_departamento_id"
  end

  create_table "alunos", force: :cascade do |t|
    t.string "course"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "matricula"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  create_table "departamentos", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "formularios", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.datetime "created_at", null: false
    t.string "status"
    t.string "target_role"
    t.integer "template_id"
    t.string "title"
    t.integer "turma_id", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_formularios_on_admin_id"
    t.index ["template_id"], name: "index_formularios_on_template_id"
    t.index ["turma_id"], name: "index_formularios_on_turma_id"
  end

  create_table "professors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "departamento_id", null: false
    t.string "email"
    t.string "formation"
    t.string "matricula"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["departamento_id"], name: "index_professors_on_departamento_id"
  end

  create_table "questaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "enunciado"
    t.integer "formulario_id"
    t.integer "template_id"
    t.string "tipo"
    t.datetime "updated_at", null: false
    t.index ["formulario_id"], name: "index_questaos_on_formulario_id"
    t.index ["template_id"], name: "index_questaos_on_template_id"
  end

  create_table "resposta", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "questao_id", null: false
    t.integer "submissao_id", null: false
    t.datetime "updated_at", null: false
    t.integer "valor_numerico"
    t.text "valor_texto"
    t.index ["questao_id"], name: "index_resposta_on_questao_id"
    t.index ["submissao_id"], name: "index_resposta_on_submissao_id"
  end

  create_table "submissaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "formulario_id", null: false
    t.integer "participant_id", null: false
    t.string "participant_type", null: false
    t.datetime "updated_at", null: false
    t.index ["formulario_id"], name: "index_submissaos_on_formulario_id"
    t.index ["participant_type", "participant_id"], name: "index_submissaos_on_participant"
  end

  create_table "templates", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.datetime "created_at", null: false
    t.string "target_role"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_templates_on_admin_id"
  end

  create_table "turma_alunos", force: :cascade do |t|
    t.integer "aluno_id", null: false
    t.datetime "created_at", null: false
    t.integer "turma_id", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id"], name: "index_turma_alunos_on_aluno_id"
    t.index ["turma_id"], name: "index_turma_alunos_on_turma_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.string "class_code"
    t.datetime "created_at", null: false
    t.integer "departamento_id", null: false
    t.integer "professor_id", null: false
    t.string "semester"
    t.string "subject_code"
    t.string "subject_name"
    t.string "time"
    t.datetime "updated_at", null: false
    t.index ["departamento_id"], name: "index_turmas_on_departamento_id"
    t.index ["professor_id"], name: "index_turmas_on_professor_id"
  end

  add_foreign_key "admins", "departamentos"
  add_foreign_key "formularios", "admins"
  add_foreign_key "formularios", "templates"
  add_foreign_key "formularios", "turmas"
  add_foreign_key "professors", "departamentos"
  add_foreign_key "questaos", "formularios"
  add_foreign_key "questaos", "templates"
  add_foreign_key "resposta", "questaos"
  add_foreign_key "resposta", "submissaos"
  add_foreign_key "submissaos", "formularios"
  add_foreign_key "templates", "admins"
  add_foreign_key "turma_alunos", "alunos"
  add_foreign_key "turma_alunos", "turmas"
  add_foreign_key "turmas", "departamentos"
  add_foreign_key "turmas", "professors"
end
