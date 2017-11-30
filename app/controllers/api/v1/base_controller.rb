module Api::V1
  class BaseController < ::ApplicationController

    respond_to :json
    protect_from_forgery with: :null_session

    rescue_from ActiveRecord::RecordNotFound do |exc|
      render :nothing, status: 404
    end

  end
end
