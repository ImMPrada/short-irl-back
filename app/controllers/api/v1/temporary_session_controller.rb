module Api
  module V1
    class TemporarySessionController < ApplicationController
      def create
        @temporary_session = TemporarySession.new
        return render json: { message: 'not created' }, status: :unprocessable_entity unless @temporary_session.valid?

        @temporary_session.save
        render json: { token: @temporary_session.uuid }, status: :created
      end
    end
  end
end
