require 'rails_helper'

RSpec.describe "Formularios", type: :request do
  describe "GET /formularios/:id/exportar_csv" do
    it "retorna um arquivo CSV de sucesso com as respostas da avaliação" do
      # 1. Base
      departamento = Departamento.new
      departamento.save(validate: false)

      admin = Admin.new(departamento_id: departamento.id)
      admin.save(validate: false)

      professor = Professor.new(departamento_id: departamento.id)
      professor.save(validate: false)

      template = Template.new(admin_id: admin.id)
      template.save(validate: false)

      turma = Turma.new(departamento_id: departamento.id, professor_id: professor.id)
      turma.save(validate: false)

      formulario = Formulario.new(turma_id: turma.id, template_id: template.id, admin_id: admin.id)
      formulario.save(validate: false)

      get exportar_csv_formulario_path(formulario, format: :csv)

      # Validações
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/csv')
      expect(response.body).to include("ID da Pergunta", "Enunciado")
    end
  end
end