class ApidocsController < ActionController::Base
  include Swagger::Blocks

 swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'Instabug challenge'
      key :description, 'API document'
      contact do
        key :name, 'Mohamed Medhat Ashour'
      end
    end
    key :host, 'localhost:3000'
    key :basePath, '/'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
      Api::V1::ChatApplicationsController,
      Api::V1::MessagesController,
      Api::V1::ChatsController,
      ChatApplication,
      Message,
      Chat,
      self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
