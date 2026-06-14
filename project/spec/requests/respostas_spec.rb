require 'rails_helper'

RSpec.describe "Respostas", type: :request do
  describe "POST /resposta" do
    it "cria uma nova resposta mapeando a nota corretamente para o atributo do banco" do
      # 1. Base da hierarquia
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

      # 2. Cria o Aluno para satisfazer o polimorfismo da Submissão
      aluno = Aluno.new
      aluno.save(validate: false)

      submissao = Submissao.new(
        formulario_id: formulario.id, 
        participant_id: aluno.id, 
        participant_type: 'Aluno'
      )
      submissao.save(validate: false)

      questao = Questao.new(template_id: template.id)
      questao.save(validate: false)

      # Parâmetros usando o nome exato do Schema para sincronização perfeita
      parametros = {
        respostum: {
          valor_numerico: 10,
          valor_texto: "Ótima aula",
          submissao_id: submissao.id,
          questao_id: questao.id
        }
      }

      # Valida se o registro foi criado no banco
      expect {
        post "/resposta", params: parametros
      }.to change(Respostum, :count).by(1)

      expect(response).to be_redirect
      
      # Garante a sincronização
      nova_resposta = Respostum.last
      expect(nova_resposta.valor_numerico).to eq(10)
    end
  end
end