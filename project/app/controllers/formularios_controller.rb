class FormulariosController < ApplicationController
  before_action :set_formulario, only: %i[ show edit update destroy exportar_csv ]
  before_action :set_select_options, only: %i[ new create edit update ]

  # GET /formularios or /formularios.json
  def index
    @formularios = current_admin ? current_admin.formularios : Formulario.all
  end

  # GET /formularios/1 or /formularios/1.json
  def show
  end

  # GET /formularios/new
  def new
    @formulario = Formulario.new(admin_id: current_admin&.id)
  end

  # GET /formularios/1/edit
  def edit
  end

  # POST /formularios or /formularios.json
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
    # Use callbacks to share common setup or constraints between actions.
    def set_formulario
      @formulario = Formulario.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def formulario_params
      attrs = params.expect(formulario: [ :title, :target_role, :status, :template_id, :turma_id, :admin_id ])
      attrs[:admin_id] = current_admin.id if current_admin
      attrs
    end

    # Opções disponíveis para os selects de template e turma do formulário.
    def set_select_options
      @templates = current_admin ? current_admin.templates : Template.all
      @turmas = Turma.all
    end
end
