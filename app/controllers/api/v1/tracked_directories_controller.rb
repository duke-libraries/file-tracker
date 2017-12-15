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

    # GET /:id/changes
    def changes
      dir = TrackedDirectory.find(params.require(:id))

      respond_to do |format|
        format.json do
          render json: dir.pending_changes
        end

        format.csv do
          # TODO
        end
      end
    end

  end
end
