module ResponseHandler
  extend ActiveSupport::Concern

  def json_response(hash_object, status = :ok)
    render json: hash_object, status: status
  end

  def render_response(object, status = :ok, messages = [], errors = [])
    json_response( { data: object, errors: [errors], messages: messages }, status)
  end

  def render_forbidden_response(object = {}, messages = [], errors = [])
    render_response(object, :forbidden, messages, errors)
  end

  def render_unprocessable_response(object = {}, messages = [], errors = [])
    render_response(object, :unprocessable_entity, messages, errors)
  end
end
