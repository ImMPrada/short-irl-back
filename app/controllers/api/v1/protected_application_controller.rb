module Api
  module V1
    class ProtectedApplicationController < ApplicationController
      before_action :authenticate_request

      include ActionController::Cookies

      private

      def authenticate_request
        return if request.headers['Authorization'].present?

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def token
        return unless bearer_token?

        @token ||= request.headers['Authorization'].split('Bearer ')&.last
      end

      def current_user
        return unless token

        jwt_payload = Warden::JWTAuth::TokenDecoder.new.call(token)
        @current_user ||= User.find(jwt_payload['sub'])
      end

      def temporary_session_token
        return unless temporary_session_token?

        @temporary_session_token ||= request.headers['Authorization']&.split('Token ')&.last
      end

      def temporary_session
        return unless temporary_session_token

        @temporary_session ||= TemporarySession.find_by(uuid: temporary_session_token)
      end

      def temporary_session_token?
        request.headers['Authorization'].split('Token ').size > 1
      end

      def bearer_token?
        request.headers['Authorization'].split('Bearer ').size > 1
      end
    end
  end
end
