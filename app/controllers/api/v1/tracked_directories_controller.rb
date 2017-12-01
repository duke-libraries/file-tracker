module Api::V1
  class TrackedDirectoriesController < BaseController

    # GET /
    # HEAD /
    def index
      render json: TrackedDirectory.all
    end

    # GET /:id
    # HEAD /:id
    def show
      render json: TrackedDirectory.find(params.require(:id))
    end

  end
end
