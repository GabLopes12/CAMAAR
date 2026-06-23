module Formularios
  class CreateFromTemplate
    Result = Data.define(:formulario, :success?)

    def initialize(admin:, params:)
      @admin = admin
      @params = params
    end

    def call
      formulario = Formulario.new(@params)
      formulario.admin = @admin
      formulario.target_role = template&.target_role

      if formulario.save
        clone_questoes(formulario)
        Result.new(formulario:, success?: true)
      else
        Result.new(formulario:, success?: false)
      end
    end

    private

    def template
      Template.find_by(id: @params[:template_id])
    end

    def clone_questoes(formulario)
      template&.questaos&.each do |questao|
        formulario.questaos.create!(enunciado: questao.enunciado, tipo: questao.tipo)
      end
    end
  end
end
