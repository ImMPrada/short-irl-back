module Api
  module V1
    class CurrentUserController < ProtectedApplicationController
      before_action :authenticate_request

    include SessionResponse

      def resolve_user
        return destroy_session unless current_user

        @user = current_user
      end

      private

      def destroy_session
        destroy_cookie
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
