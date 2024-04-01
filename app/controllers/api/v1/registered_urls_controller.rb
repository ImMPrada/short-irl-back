module Api
  module V1
    class RegisteredUrlsController < ProtectedApplicationController
      def index
        @registered_urls = session.registered_urls.active.not_expired
      end

      def create
        @registered_url = session.registered_urls.new(registered_url_params)

        unless @registered_url.valid?
          return render json: { errors: @registered_url.errors }, status: :unprocessable_entity
        end

        @registered_url.save!
      end

      private

      def registered_url_params
        params.require(:'registered-url').permit(:url)
      end
    end
  end
end
