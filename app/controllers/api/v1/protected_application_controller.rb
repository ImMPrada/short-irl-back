module Api
  module V1
    class ProtectedApplicationController < ApplicationController
      before_action :authenticate_request, only: %i[index create destroy]

      private

      def authenticate_request
        return if token && session

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def token
        @token ||= request.headers['Authorization']&.split(' ')&.last
      end

      def session
        @session ||= TemporarySession.find_by(uuid: token)
      end
    end
  end
end
