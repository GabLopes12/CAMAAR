class RespostaController < ApplicationController
  before_action :require_login

  # POST /resposta or /resposta.json
  def create
    # Caminho Triste: Valida se o campo de nota foi deixado em branco pelo robô/usuário
    if params.dig(:respostum, :valor_numerico).blank?
      redirect_to formulario_path(params[:respostum][:formulario_id]), alert: "Por favor, preencha todas as questões obrigatórias"
      return
    end

    # Caminho Feliz: Cria a submissão vinculando o usuário e o formulário (idêntico ao banco)
    @submissao = Submissao.find_or_create_by!(
      user_id: current_user.id,
      formulario_id: params[:respostum][:formulario_id]
    )

    # Cria a resposta vinculando à questão e à submissão recém-criada
    @respostum = Respostum.new(
      valor_numerico: params[:respostum][:valor_numerico],
      questao_id: params[:respostum][:questao_id],
      submissao_id: @submissao.id
    )

    if @respostum.save
      redirect_to formularios_path, notice: "Avaliação submetida com sucesso"
    else
      redirect_to formulario_path(params[:respostum][:formulario_id]), alert: "Por favor, preencha todas as questões obrigatórias"
    end
  end

end
