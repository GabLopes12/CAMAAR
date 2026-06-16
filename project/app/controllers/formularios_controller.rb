class FormulariosController < ApplicationController
  before_action :require_admin!
  before_action :set_formulario, only: %i[ show edit update destroy exportar_csv ]
  before_action :set_select_options, only: %i[ new create edit update ]

  def index
    @formularios = current_admin.formularios
  end

  def show
  end

  def new
    @formulario = Formulario.new
  end

  def edit
  end

  def create
    @formulario = Formulario.new(formulario_params)
    @formulario.target_role ||= @formulario.template&.target_role

    if @formulario.save
      @formulario.template.questaos.each do |questao|
        @formulario.questaos.create!(enunciado: questao.enunciado, tipo: questao.tipo)
      end
      redirect_to formularios_path, notice: "Formulário gerado com sucesso!"
    else
      render :new, status: :unprocessable_content
    end
  end

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

  def destroy
    @formulario.destroy!
    respond_to do |format|
      format.html { redirect_to formularios_path, notice: "Formulario was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

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
    attrs = params.expect(formulario: [ :title, :target_role, :status, :template_id, :course_class_id ])
    attrs[:admin_id] = current_admin.id
    attrs
  end

  def set_select_options
    @templates = current_admin.templates
    @course_classes = CourseClass.all
  end
end
