# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  include ActionController::Cookies

  respond_to :json

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  private

  def respond_with(current_user, _opts = {})
    return build_failed_response unless current_user.persisted?

    token = request.env['warden-jwt_auth.token']
    build_success_response(token)
  end

  def build_success_response(token)
    create_cookie(token)

    render json: {
      status: {
        code: 200, message: 'Logged in successfully.',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last

      jwt_payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      current_user = User.find(jwt_payload['sub'])
    end

    build_on_destroy_response(current_user)
  end

  def create_cookie(token)
    cookies[:shorter] = {
      value: token,
      httponly: true,
      secure: true,
      same_site: true
    }
  end

  def build_on_destroy_response(current_user)
    if current_user
      return render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    end

    render json: {
      status: 401,
      message: "Couldn't find an active session."
    }, status: :unauthorized
  end
  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
