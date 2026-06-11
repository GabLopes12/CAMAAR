class SubmissaosController < ApplicationController
  before_action :set_submissao, only: %i[ show edit update destroy ]

  # GET /submissaos or /submissaos.json
  def index
    @submissaos = Submissao.all
  end

  # GET /submissaos/1 or /submissaos/1.json
  def show
  end

  # GET /submissaos/new
  def new
    @submissao = Submissao.new
  end

  # GET /submissaos/1/edit
  def edit
  end

  # POST /submissaos or /submissaos.json
  def create
    @submissao = Submissao.new(submissao_params)

    respond_to do |format|
      if @submissao.save
        format.html { redirect_to @submissao, notice: "Submissao was successfully created." }
        format.json { render :show, status: :created, location: @submissao }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @submissao.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /submissaos/1 or /submissaos/1.json
  def update
    respond_to do |format|
      if @submissao.update(submissao_params)
        format.html { redirect_to @submissao, notice: "Submissao was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @submissao }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @submissao.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /submissaos/1 or /submissaos/1.json
  def destroy
    @submissao.destroy!

    respond_to do |format|
      format.html { redirect_to submissaos_path, notice: "Submissao was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submissao
      @submissao = Submissao.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def submissao_params
      params.expect(submissao: [ :formulario_id, :participant_id, :participant_type ])
    end
end
