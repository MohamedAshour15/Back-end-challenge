module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: error_message(e), status: :unprocessable_entity
    end

    rescue_from ArgumentError do |e|
      render json: error_message(e), status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotUnique do |e|
      render json: error_message(e), status: :bad_request
    end
  end

  def error_message(e)
    { errors: [e.message] }
  end
end
