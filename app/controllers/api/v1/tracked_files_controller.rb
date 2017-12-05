module Api::V1
  class TrackedFilesController < ::ApplicationController

    # GET /:id
    # HEAD /:id
    def show
      render json: TrackedFile.find(params.require(:id))
    end

  end
end
