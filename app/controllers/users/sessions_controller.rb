# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  include SessionResponse

  respond_to :json

  LOGGED_IN_MESSAGE = 'Logged in successfully.'
  LOGGED_OUT_MESSAGE = 'Logged out successfully.'
  FAILEED_LOGG_OUT_MESSAGE = "Couldn't find an active session."

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super

    temporary_session_uuid = extract_temporary_session_token
    RegisteredUrls::Transferor.new.transfer_to_user(user: current_user, temporary_session_uuid:)
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  private

  def respond_with(_current_user, _opts = {})
    token = request.env['warden-jwt_auth.token']
    build_success_response(token, LOGGED_IN_MESSAGE)
  end

  def respond_to_on_destroy
    token = request.cookies['shortener']

    if token
      jwt_payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      current_user = User.find(jwt_payload['sub'])
    end

    build_on_destroy_response(current_user)
  end

  def build_on_destroy_response(current_user)
    return render json: { message: FAILEED_LOGG_OUT_MESSAGE }, status: :unauthorized unless current_user

    destroy_cookie
    render json: { message: LOGGED_OUT_MESSAGE }, status: :ok
  end

  def extract_temporary_session_token
    return unless request.headers['Authorization']

    splited_authotization_header = request.headers['Authorization'].split('Token ')
    return if splited_authotization_header.size == 1

    splited_authotization_header.last
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
