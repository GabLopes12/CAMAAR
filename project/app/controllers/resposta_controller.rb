class RespostaController < ApplicationController
  before_action :require_login

  # POST /resposta or /resposta.json
  def create
    @formulario = Formulario.find(params[:respostum][:formulario_id])
    @respostas_params = params[:respostum][:respostas] || {}

    # Caminho Triste: alguma questão do formulário foi deixada em branco
    if questao_em_branco?
      redirect_to formulario_path(@formulario), alert: "Por favor, preencha todas as questões obrigatórias"
      return
    end

    # Caminho Feliz: cria a submissão e todas as respostas em uma única transação
    submissao = Submissao.find_or_create_by!(user: current_user, formulario: @formulario)

    Respostum.transaction do
      @formulario.questaos.each do |questao|
        respostum = Respostum.find_or_initialize_by(submissao: submissao, questao: questao)
        atribuir_valor(respostum, questao)
        respostum.save!
      end
    end

    redirect_to formularios_path, notice: "Avaliação submetida com sucesso"
  end

  private
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
