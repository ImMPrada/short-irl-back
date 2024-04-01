module Api
  module V1
    class RegisteredUrlsController < ProtectedApplicationController
      def index
        @registered_urls = session.registered_urls.active.not_expired
      end
    end
  end
end
