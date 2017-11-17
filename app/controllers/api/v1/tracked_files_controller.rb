module Api::V1
  class TrackedFilesController < ::ApplicationController

    respond_to :json
    protect_from_forgery with: :null_session

    rescue_from ActiveRecord::RecordNotFound do |exc|
      render :nothing, status: 404
    end

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

    # GET /*id
    # HEAD /*id
    # :id may be a TrackedFile id or path.
    def show
      id = params[:id].to_i
      tracked_file = if id == 0
                       puts params[:id]
                       TrackedFile.find_by!(path: params[:id])
                     else
                       TrackedFile.find(id)
                     end
      render json: tracked_file
    end

    private

    def create_params
      params.permit(:path, :sha1, :md5, :size)
    end

  end
end
