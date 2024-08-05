module Api
  module V1
    class CurrentUsersController < ProtectedApplicationController
      before_action :authenticate_request

    include SessionResponse

      def show
        return destroy_session unless current_user

        @user = current_user
      end

      private

      def destroy_session
        destroy_cookie
        ender json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
