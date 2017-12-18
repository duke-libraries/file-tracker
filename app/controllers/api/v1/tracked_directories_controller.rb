module Api::V1
  class TrackedDirectoriesController < BaseController

    # GET /
    # HEAD /
    def index
      respond_with(TrackedDirectory.all)
    end

    # GET /:id
    # HEAD /:id
    def show
      dir = TrackedDirectory.find(params.require(:id))
      respond_with(dir)
    end

    # GET /:id/changes
    def changes
      dir = TrackedDirectory.find(params.require(:id))
      respond_with(dir.pending_changes)
    end

  end
end
