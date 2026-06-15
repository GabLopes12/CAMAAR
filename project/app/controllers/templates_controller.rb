class TemplatesController < ApplicationController
  before_action :set_template, only: %i[ show edit update destroy ]
  before_action :authorize_template_access!, only: %i[ show edit update destroy ]

  # GET /templates or /templates.json
  def index
    @templates = current_admin ? current_admin.templates : Template.all
  end

  # GET /templates/1 or /templates/1.json
  def show
  end

  # GET /templates/new
  def new
    @template = Template.new(admin_id: current_admin&.id)
    @questoes_attrs = []
  end

  # GET /templates/1/edit
  def edit
    @questoes_attrs = @template.questaos.map do |questao|
      { id: questao.id, enunciado: questao.enunciado, tipo: questao.tipo }
    end
  end

  # POST /templates or /templates.json
  def create
    @template = Template.new(template_params)
    @questoes_attrs = extract_questoes_attrs

    if params[:add_questao]
      @questoes_attrs << blank_questao_attrs
      return render :new, status: :ok
    end

    if @template.valid? && questoes_attrs_valid?
      Template.transaction do
        @template.save!
        @questoes_attrs.each do |questao|
          @template.questaos.create!(enunciado: questao[:enunciado], tipo: questao[:tipo])
        end
      end
      redirect_to templates_path, notice: "Template criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /templates/1 or /templates/1.json
  def update
    @template.assign_attributes(template_params)
    @questoes_attrs = extract_questoes_attrs

    if params[:add_questao]
      @questoes_attrs << blank_questao_attrs
      return render :edit, status: :ok
    end

    novas_questoes = @questoes_attrs.reject { |questao| questao[:id].present? }

    if @template.valid? && novas_questoes_validas?(novas_questoes)
      Template.transaction do
        @template.save!
        @questoes_attrs.each do |questao|
          if questao[:id].present?
            @template.questaos.find(questao[:id]).update!(enunciado: questao[:enunciado], tipo: questao[:tipo])
          else
            @template.questaos.create!(enunciado: questao[:enunciado], tipo: questao[:tipo])
          end
        end
      end
      redirect_to templates_path, notice: "Template atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /templates/1 or /templates/1.json
  def destroy
    @template.destroy!
    redirect_to templates_path, notice: "Template deletado com sucesso.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params.expect(:id))
    end

    # Garante que o admin só acesse/edite/delete templates criados por ele.
    def authorize_template_access!
      return if current_admin.nil? || @template.admin_id == current_admin.id

      redirect_to templates_path, alert: "Você não tem acesso a esse template"
    end

    # Only allow a list of trusted parameters through.
    def template_params
      attrs = params.expect(template: [ :title, :target_role, :admin_id ])
      attrs[:admin_id] = current_admin.id if current_admin
      attrs
    end

    # Extrai as questões enviadas via template[questaos][i][enunciado/tipo/id].
    def extract_questoes_attrs
      raw = params.dig(:template, :questaos)
      return [] unless raw

      raw.values.map do |questao|
        attrs = { enunciado: questao[:enunciado].to_s, tipo: questao[:tipo].presence || "rating" }
        attrs[:id] = questao[:id] if questao[:id].present?
        attrs
      end
    end

    def blank_questao_attrs
      { enunciado: "", tipo: "rating" }
    end

    def questoes_attrs_valid?
      if @questoes_attrs.any? { |questao| questao[:enunciado].blank? }
        @template.errors.add(:base, "Questão não possui enunciado")
        false
      else
        true
      end
    end

    def novas_questoes_validas?(novas_questoes)
      if novas_questoes.any? { |questao| questao[:enunciado].blank? }
        @template.errors.add(:base, "A nova questão não possui enunciado")
        false
      else
        true
      end
    end
end
