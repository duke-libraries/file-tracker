module Api::V1
  class TrackedFilesController < ::ApplicationController

    # POST /
    # Query params: path, sha1, size
    def create
      tracked_file = TrackedFile.new(create_params)
      if tracked_file.save
        render json: tracked_file, status: 201
      else
        render json: tracked_file.errors, status: 403
      end
    end

    # GET /:id
    # HEAD /:id
    def show
      render json: TrackedFile.find(params.require(:id))
    end

    private

    def create_params
      params.permit(:path, :sha1, :md5, :size)
    end

  end
end
