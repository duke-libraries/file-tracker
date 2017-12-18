module Api::V1
  class TrackedFilesController < BaseController

    # GET /:id
    # HEAD /:id
    def show
      file = TrackedFile.find(params.require(:id))
      respond_with(file)
    end

  end
end
