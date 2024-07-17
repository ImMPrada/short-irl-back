module Api
  module V1
    class RegisteredUrlsController < ProtectedApplicationController
      skip_before_action :authenticate_request, only: [:show]

      def index
        @registered_urls = []
        @registered_urls = temporary_session.registered_urls.active.not_expired unless temporary_session_token.nil?
        @registered_urls = current_user.registered_urls.active.not_expired unless token.nil?
      end

      def show
        @registered_url = RegisteredUrl.find_by(uuid: params[:id])

        return render json: { errors: 'registered url not found' }, status: :not_found if @registered_url.nil?

        @registered_url.url_visits.create!
        render :show
      end

      def create
        url = registered_url_params[:url]
        unless temporary_session_token.nil?
          @registered_url = RegisteredUrls::Creator.new.create_for_temporary_session(temporary_session:,
                                                                                     url:)
        end
        @registered_url = RegisteredUrls::Creator.new.create_for_user(user: current_user, url:) unless token.nil?
      rescue StandardError => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      def destroy
        @registered_url = temporary_session.registered_urls.find_by(uuid: params[:id])
        return render json: { errors: 'registered url not found' }, status: :not_found unless @registered_url

        @registered_url.active = false
        @registered_url.expires_at = Time.zone.now

        unless @registered_url.valid?
          return render json: { errors: @registered_url.errors }, status: :unprocessable_entity
        end

        @registered_url.save!
      end

      private

      def registered_url_params
        params.require(:registered_url).permit(:url)
      end
    end
  end
end
