class FormulariosController < ApplicationController
  before_action :require_admin!, only: %i[ new create destroy exportar_csv ]
  before_action :set_formulario, only: %i[ show destroy exportar_csv ]
  before_action :authorize_formulario_access!, only: %i[ destroy ]

  # GET /formularios or /formularios.json
  def index
    # Issue 110: Visualizar os formulários criados (Listagem geral)
    @formularios = current_admin ? current_admin.formularios : []

    # Issue 109: Visualizar os formulários não respondidos das turmas, respeitando
    # o papel (discente/docente) do usuário em cada turma
    @formularios_pendentes = current_user ? formularios_pendentes_para(current_user) : []
  end

  # GET /formularios/1 or /formularios/1.json
  def show
    if current_admin
      @resultados = @formulario.questaos.includes(respostas: { submissao: :user })
      @tem_submissoes = Submissao.where(formulario: @formulario).exists?
    end
  end

  # GET /formularios/new
  def new
    @formulario = Formulario.new
    @templates = current_admin.templates
    @course_classes = CourseClass.all
  end

  # POST /formularios or /formularios.json
  def create
    result = Formularios::CreateFromTemplate.new(admin: current_admin, params: formulario_params).call
    @formulario = result.formulario

    result.success? ? render_create_success : render_create_failure
  end

  # DELETE /formularios/1
  def destroy
    @formulario.destroy!
    redirect_to formularios_path, notice: "Formulário deletado com sucesso.", status: :see_other
  end

  # GET /formularios/1/exportar_csv
  def exportar_csv
    send_data gerar_csv,
              filename: "respostas_formulario_#{@formulario.id}.csv",
              type: "text/csv"
  end

  private
    def set_formulario
      @formulario = Formulario.find(params.expect(:id))
    end

    def authorize_formulario_access!
      redirect_to formularios_path, alert: "Você não tem acesso a esse formulário" unless @formulario.admin_id == current_admin.id
    end

    def formulario_params
      params.expect(formulario: [ :title, :status, :template_id, :course_class_id ])
    end

    def formularios_pendentes_para(user)
      formularios_respondidos_ids = Submissao.where(user: user).select(:formulario_id)
      mapa = papel_por_turma(user)

      Formulario
        .where(course_class_id: mapa.keys)
        .where.not(id: formularios_respondidos_ids)
        .select { |formulario| mapa[formulario.course_class_id] == formulario.target_role }
    end

    def papel_por_turma(user)
      user.class_memberships.each_with_object({}) { |m, h| h[m.course_class_id] = m.role }
    end

    def gerar_csv
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << cabecalho_csv
        @formulario.questaos.each { |q| csv << linha_csv(q) }
      end
    end

    def cabecalho_csv
      [ "ID da Pergunta", "Enunciado", "Tipo", "Respostas" ]
    end

    def linha_csv(questao)
      valores = questao.respostas.map { |r| helpers.formatar_resposta(r, questao.tipo) }
      [ questao.id, questao.enunciado, questao.tipo, valores.join("; ") ]
    end

    def render_create_success
      respond_to do |format|
        format.html { redirect_to formularios_path, notice: "Formulário gerado com sucesso!" }
        format.json { render :show, status: :created, location: @formulario }
      end
    end

    def render_create_failure
      @templates = current_admin.templates
      @course_classes = CourseClass.all
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @formulario.errors, status: :unprocessable_content }
      end
    end
end
