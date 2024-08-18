# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  include RackSessionsFix
  include SessionResponse

  SUCCESSFULL_SIGN_UP_MESSAGE = 'Signed up successfully.'
  FAILED_SIGN_UP_MESSAGE = "User couldn't be created."

  respond_to :json

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  private

  def respond_with(current_user, _opts = {})
    return build_failed_response(FAILED_SIGN_UP_MESSAGE, current_user.errors) unless current_user.persisted?

    token = request.env['warden-jwt_auth.token']
    build_success_response(token, SUCCESSFULL_SIGN_UP_MESSAGE)
  end

  # protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username confirm_password])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
    temporary_session_uuid = extract_temporary_session_token
    return unless temporary_session_uuid

    RegisteredUrls::Transferor.new.transfer_to_user(user: resource, temporary_session_uuid:)
  end

  def extract_temporary_session_token
    return unless request.headers['Authorization']

    splited_authotization_header = request.headers['Authorization'].split('Token ')
    return if splited_authotization_header.size == 1

    splited_authotization_header.last
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
