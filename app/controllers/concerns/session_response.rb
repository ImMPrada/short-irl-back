module SessionResponse
  extend ActiveSupport::Concern
  include ActionController::Cookies

  private

  def build_success_response(token, message)
    create_cookie(token)
    response = {
      message:,
      data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
    }
    response[:data][:token] = cookies[:shorter] unless Rails.env.production?

    render json: response, status: :ok
  end

  def build_failed_response(message, current_user = null)
    render json: {
      message:,
      errors: current_user ? current_user.errors : 'Unauthorized'
    }, status: :unprocessable_entity
  end

  def create_cookie(token)
    cookies[:shorter] = {
      value: token,
      httponly: true,
      secure: true,
      same_site: true
    }
  end
end
