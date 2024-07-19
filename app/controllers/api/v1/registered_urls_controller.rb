module Api
  module V1
    class RegisteredUrlsController < ProtectedApplicationController
      skip_before_action :authenticate_request, only: [:show]

      def index
        @registered_urls = []
        @registered_urls = temporary_session.registered_urls.active.not_expired unless temporary_session.nil?
        @registered_urls = current_user.registered_urls.active.not_expired unless current_user.nil?
      end

      def show
        @registered_url = RegisteredUrl.find_by(uuid: params[:id])

        return render json: { errors: 'registered url not found' }, status: :not_found if @registered_url.nil?

        @registered_url.url_visits.create!
        render :show
      end

      def create
        url = registered_url_params[:url]
        creator = RegisteredUrls::Creator.new

        unless temporary_session_token.nil?
          @registered_url = creator.create_for_temporary_session(temporary_session:, url:)
        end
        @registered_url = creator.create_for_user(user: current_user, url:) unless token.nil?
      rescue StandardError => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      def destroy
        uuid = params[:id]
        disabler = RegisteredUrls::Disabler.new

        unless temporary_session_token.nil?
          @registered_url = disabler.disable_for_temporary_session(temporary_session:, uuid:)
        end
        @registered_url = disabler.disable_for_user(user: current_user, uuid:) unless token.nil?
      rescue StandardError => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      private

      def registered_url_params
        params.require(:registered_url).permit(:url)
      end
    end
  end
end
