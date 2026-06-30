class SessionsController < ApplicationController
  layout "auth"

  def new
  end

  def create
    user = User.find_for_login(session_params[:identifier])

    return handle_pending_setup if user&.pending_password_setup?
    return handle_login_success(user) if user&.authenticate(session_params[:password])

    handle_login_failure
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logout realizado com sucesso"
  end

  private

  def session_params
    params.require(:session).permit(:identifier, :password)
  end

  def handle_pending_setup
    flash.now[:alert] = "Senha inicial precisa ser definida antes do acesso"
    render :new, status: :unprocessable_entity
  end

  def handle_login_success(user)
    session[:user_id] = user.id
    redirect_to root_path, notice: "Login realizado com sucesso"
  end

  def handle_login_failure
    flash.now[:alert] = "Email, matrícula ou senha inválidos"
    render :new, status: :unprocessable_entity
  end
end
