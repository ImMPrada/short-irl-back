module SessionResponse
  extend ActiveSupport::Concern
  include ActionController::Cookies

  private

  def build_success_response(token, message)
    create_cookie(token)
    @message = message
    @user = current_user

    render :create, status: :ok
  end

  def build_failed_response(message, errors = null)
    render json: {
      message:,
      errors: errors || 'Unauthorized'
    }, status: :unprocessable_entity
  end

  def build_unauthorized_response
    destroy_cookie
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def create_cookie(token)
    cookies[:shortener] = {
      value: token,
      httponly: true,
      secure: true,
      same_site: :none,
      expires: 1.month.from_now.utc
    }
  end

  def destroy_cookie
    cookies.delete(:shortener)
  end
end
