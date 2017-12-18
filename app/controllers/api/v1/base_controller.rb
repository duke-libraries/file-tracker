module Api::V1
  class BaseController < ::ActionController::API
    include ActionController::MimeResponds

    respond_to :json, :csv

    rescue_from ActiveRecord::RecordNotFound do |exc|
      render :nothing, status: 404
    end

  end
end
