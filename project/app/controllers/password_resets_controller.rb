class PasswordResetsController < ApplicationController
  layout "auth"

  GENERIC_MESSAGE = "Se o email estiver cadastrado, você receberá instruções para redefinir sua senha"

  def new
  end

  def create
    user = User.find_by(email: reset_request_params[:email].to_s.strip.downcase)
    UserMailer.password_reset(user, user.generate_password_reset_token!).deliver_now if user

    redirect_to new_password_reset_path, notice: GENERIC_MESSAGE
  end

  def edit
    load_user
    render_invalid_token unless @user
  end

  def update
    load_user
    return render_invalid_token unless @user
    return render_password_mismatch unless passwords_match?

    apply_password_reset
  end

  private

  def load_user
    @token = params[:token]
    @user = User.find_by_reset_token(@token)
  end

  def reset_request_params
    params.require(:password_reset).permit(:email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def render_invalid_token
    flash.now[:alert] = "Link de redefinição de senha inválido ou expirado"
    render :invalid, status: :not_found
  end

  def passwords_match?
    password_params[:password] == password_params[:password_confirmation]
  end

  def render_password_mismatch
    flash.now[:alert] = "Confirmação de senha não confere"
    render :edit, status: :unprocessable_entity
  end

  def apply_password_reset
    @user.apply_new_password!(password_params[:password])
    redirect_to login_path, notice: "Senha redefinida com sucesso"
  end
end
