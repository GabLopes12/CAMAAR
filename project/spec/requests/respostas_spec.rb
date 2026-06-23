require 'rails_helper'

RSpec.describe "Respostas", type: :request do
  describe "POST /resposta" do
    it "cria uma nova resposta mapeando a nota corretamente para o atributo do banco" do
      user = create(:user)
      formulario = create(:formulario)
      questao = create(:questao, :de_formulario, formulario: formulario)

      login_as(user)

      parametros = {
        respostum: {
          valor_numerico: 10,
          valor_texto: "Ótima aula",
          formulario_id: formulario.id,
          questao_id: questao.id
        }
      }

      expect {
        post "/resposta", params: parametros
      }.to change(Respostum, :count).by(1)

      expect(response).to be_redirect

      nova_resposta = Respostum.last
      expect(nova_resposta.valor_numerico).to eq(10)
    end

    it "não cria a resposta quando a nota é deixada em branco" do
      user = create(:user)
      formulario = create(:formulario)
      questao = create(:questao, :de_formulario, formulario: formulario)

      login_as(user)

      parametros = {
        respostum: {
          valor_numerico: "",
          formulario_id: formulario.id,
          questao_id: questao.id
        }
      }

      expect {
        post "/resposta", params: parametros
      }.not_to change(Respostum, :count)

      expect(response).to redirect_to(formulario_path(formulario))
      follow_redirect!
      expect(response.body).to include("Por favor, preencha todas as questões obrigatórias")
    end
  end
end