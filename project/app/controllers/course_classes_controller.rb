class CourseClassesController < ApplicationController
  before_action :require_admin!

  def index
    @course_classes = CourseClass.where(department: current_admin.department, semester: current_semester)
  end

  def show
    @course_class = CourseClass.find(params.expect(:id))

    if @course_class.department_id != current_admin.department_id
      redirect_to course_classes_path, alert: "Acesso negado. Você só pode gerenciar turmas do seu próprio departamento."
      return
    end

    @formularios = Formulario.where(course_class: @course_class)
  end

  private

  def current_semester
    CourseClass.maximum(:semester)
  end
end
