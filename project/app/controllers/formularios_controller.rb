class FormulariosController < ApplicationController
  before_action :require_admin!, only: %i[ new create edit update destroy exportar_csv ]
  before_action :set_formulario, only: %i[ show edit update destroy exportar_csv ]

  # GET /formularios or /formularios.json
  def index
    # Issue 110: Visualizar os formulários criados (Listagem geral)
    @formularios = Formulario.all

    # Issue 109: Visualizar os formulários não respondidos das turmas
    if current_user
      # 1. Mapeia quais formulários o usuário atual já respondeu
      formularios_respondidos_ids = Submissao.where(user_id: current_user.id).select(:formulario_id)

      # 2. Busca os formulários que pertencem às turmas do usuário E que não estão na lista de respondidos
      @formularios_pendentes = Formulario
                                .where(course_class_id: current_user.course_classes.select(:id))
                                .where.not(id: formularios_respondidos_ids)
    else
      @formularios_pendentes = []
    end
  end

  # GET /formularios/1 or /formularios/1.json
  def show
  end

  # GET /formularios/new
  def new
    @formulario = Formulario.new
    @templates = current_admin.templates
    @course_classes = CourseClass.all
  end

  # GET /formularios/1/edit
  def edit
  end

  # POST /formularios or /formularios.json
  def create
    result = Formularios::CreateFromTemplate.new(admin: current_admin, params: formulario_params).call
    @formulario = result.formulario

    respond_to do |format|
      if result.success?
        format.html { redirect_to formularios_path, notice: "Formulário gerado com sucesso!" }
        format.json { render :show, status: :created, location: @formulario }
      else
        @templates = current_admin.templates
        @course_classes = CourseClass.all
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @formulario.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /formularios/1 or /formularios/1.json
  def update
    respond_to do |format|
      if @formulario.update(formulario_params)
        format.html { redirect_to @formulario, notice: "Formulario was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @formulario }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @formulario.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /formularios/1 or /formularios/1.json
  def destroy
    @formulario.destroy!

    respond_to do |format|
      format.html { redirect_to formularios_path, notice: "Formulario was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /formularios/1/exportar_csv
  def exportar_csv
    require 'csv'
    
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID da Pergunta", "Enunciado", "Scores Atribuídos"]
    end

    send_data csv_data, 
              filename: "respostas_formulario_#{@formulario.id}.csv", 
              type: "text/csv"
  end

  private
    def set_formulario
      @formulario = Formulario.find(params.expect(:id))
    end

    def formulario_params
      params.expect(formulario: [ :title, :status, :template_id, :course_class_id ])
    end
end
