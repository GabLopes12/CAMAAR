class RespostaController < ApplicationController
  before_action :require_login

  # POST /resposta or /resposta.json
  def create
    carregar_formulario_e_respostas
    return redirect_para_formulario_com_alerta if questao_em_branco?

    submissao = Submissao.find_or_create_by!(user: current_user, formulario: @formulario)
    salvar_respostas(submissao)
    redirect_to formularios_path, notice: "Avaliação submetida com sucesso"
  end

  private
    def carregar_formulario_e_respostas
      @formulario = Formulario.find(params[:respostum][:formulario_id])
      @respostas_params = params[:respostum][:respostas] || {}
    end

    def redirect_para_formulario_com_alerta
      redirect_to formulario_path(@formulario), alert: "Por favor, preencha todas as questões obrigatórias"
    end

    def salvar_respostas(submissao)
      Respostum.transaction do
        @formulario.questaos.each do |questao|
          respostum = Respostum.find_or_initialize_by(submissao: submissao, questao: questao)
          atribuir_valor(respostum, questao)
          respostum.save!
        end
      end
    end

    def questao_em_branco?
      @formulario.questaos.any? { |questao| valor_para(questao).blank? }
    end

    def valor_para(questao)
      @respostas_params.dig(questao.id.to_s, "valor")
    end

    def atribuir_valor(respostum, questao)
      valor = valor_para(questao)

      if questao.tipo == "text"
        respostum.valor_texto = valor
        respostum.valor_numerico = nil
      else
        respostum.valor_numerico = valor
        respostum.valor_texto = nil
      end
    end
end
