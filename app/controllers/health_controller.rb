class HealthController < ApplicationController
  def index
    render json: { status: 'UP' }
  end
end
