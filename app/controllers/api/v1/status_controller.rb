module Api::V1
  class StatusController < ApiController

    def index
      render json: Status.new, status: :ok
    end

  end
end
