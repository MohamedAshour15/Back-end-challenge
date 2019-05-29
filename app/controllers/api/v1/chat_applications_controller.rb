class Api::V1::ChatApplicationsController < ApplicationController

  before_action :set_chat_application, only: [:show, :update]

  swagger_path '/api/v1/chat_applications' do
    operation :post do
      key :summary, 'Create a chat application'
      key :description, "Create a chat application and returns it's token"
      key :tags, [
        'ChatApplications'
      ]
      parameter do
        key :name, :Name
        key :in, :path
        key :description, 'Name of the application'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "Returns it's token"
      end
      response 404 do
        key :description, 'unexpected error'
        schema do
          property :errors, type: :string, example: 'Fail'
        end
      end
    end
  end

  swagger_path '/api/v1/chat_applications/{token}' do
    operation :put do
      key :summary, 'Updates application'
      key :description, "Updates application found by token"
      key :tags, [
        'ChatApplications'
      ]
      parameter do
        key :name, :token
        key :in, :path
        key :description, 'ID of contractor user'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :body
        key :in, :body
        schema do
          key :'$ref', :update_chat_application
        end
        key :required, false
      end
      response 200 do
        key :description, 'Chat application successfully updated'
      end
      response 404 do
        key :description, 'unexpected error'
        schema do
          property :errors, type: :string, example: 'Fail'
        end
      end
    end
  end
  
  def create
    chat_application = ChatApplication.new(chat_application_params)
    if chat_application.save
      json_response(chat_application.as_json)
    else
      json_response(chat_application.errors, :unprocessable_entity)
    end
  end

  def index
    json_response(ChatApplication.all.as_json)
  end

  def update
    if @chat_application.update(@chat_application_params)
      json_response(@chat_application.as_json)
    else
      json_response(@chat_application.errors, :unprocessable_entity)
    end
  end

  def show
    json_response(@chat_application.as_json)
  end

  private

  def chat_application_params
    params.permit(:token, :name)
  end

  def set_chat_application
    if (@chat_application = ChatApplication.find_by(token: params[:token])).blank?
      json_response({error: "ChatApplication not found"}, :not_found)
    end
  end
end