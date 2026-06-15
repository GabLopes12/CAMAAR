class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Login (#104) ainda não foi implementado: por ora o admin autenticado é
  # identificado pela sessão, alimentada por um parâmetro admin_id repassado
  # nos links/formulários na primeira requisição. Quando nada foi informado
  # ainda (ex: acesso direto a /templates), cai para o primeiro admin
  # cadastrado, para que a sessão fique consistente a partir da próxima requisição.
  def current_admin
    return @current_admin if defined?(@current_admin)

    session[:admin_id] = params[:admin_id] if params[:admin_id].present?
    @current_admin = Admin.find_by(id: session[:admin_id]) || Admin.first
  end
  helper_method :current_admin
end
