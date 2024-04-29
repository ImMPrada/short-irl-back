module Api
  module V1
    class RegisteredUrlsController < ProtectedApplicationController
      def index
        @registered_urls = session.registered_urls.active.not_expired
      end

      def show
        @registered_url = RegisteredUrl.find_by(uuid: params[:id])

        return render json: { errors: 'registered url not found' }, status: :not_found if @registered_url.nil?

        @registered_url.url_visits.create!
        render :show
      end

      def create
        token_urls_count = session.registered_urls.active.count
        if token_urls_count >= RegisteredUrl::MAX_TEMPORARY_SESSION_URLS
          return render json: { errors: ['maximum number of registered urls reached'] }, status: :unprocessable_entity
        end

        @registered_url = session.registered_urls.new(registered_url_params)

        unless @registered_url.valid?
          return render json: { errors: @registered_url.errors.full_messages }, status: :unprocessable_entity
        end

        @registered_url.save!
      end

      def destroy
        @registered_url = session.registered_urls.find_by(uuid: params[:id])
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
