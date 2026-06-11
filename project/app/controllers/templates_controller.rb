class TemplatesController < ApplicationController
  before_action :set_template, only: %i[ show edit update destroy ]

  # GET /templates or /templates.json
  def index
    @templates = Template.all
  end

  # GET /templates/1 or /templates/1.json
  def show
  end

  # GET /templates/new
  def new
    @template = Template.new
  end

  # GET /templates/1/edit
  def edit
  end

  # POST /templates or /templates.json
  def create
    @template = Template.new(template_params)

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: "Template was successfully created." }
        format.json { render :show, status: :created, location: @template }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @template.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /templates/1 or /templates/1.json
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to @template, notice: "Template was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @template }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @template.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /templates/1 or /templates/1.json
  def destroy
    @template.destroy!

    respond_to do |format|
      format.html { redirect_to templates_path, notice: "Template was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def template_params
      params.expect(template: [ :title, :target_role, :admin_id ])
    end
end
