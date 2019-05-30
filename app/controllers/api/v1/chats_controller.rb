class Api::V1::ChatsController < ApplicationController

  before_action :set_chat, only: [:show, :update]
  before_action :check_if_application_exists, only: [:create, :index]

  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats' do
    operation :post do
      key :summary, 'Create a chat'
      key :description, "Create a chat to the corresponding chat application"
      key :tags, [
        'Chats'
      ]
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      response 200 do
        key :description, "Chat successfully created"
      end
      response 404 do
        key :description, 'ChatApplication not found'
      end
    end
  end

  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats' do
    operation :get do
      key :summary, 'Get all chats'
      key :description, "Get all chats for an application found by token"
      key :tags, [
        'Chats'
      ]
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      response 200 do
        key :description, "Chats successfully retrieved"
      end
      response 404 do
        key :description, 'ChatApplication not found'
      end
    end
  end
  
  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats/{number}' do
    operation :get do
      key :summary, 'Get a chat'
      key :description, "Get a chat by application token and its number"
      key :tags, [
        'Chats'
      ]
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      parameter do
        key :name, :number
        key :in, :path
        key :description, 'Chat number'
        key :required, true
        key :type, :integer
      end  
      response 200 do
        key :description, "Chat successfully retrieved"
      end
      response 404 do
        key :description, 'ChatApplication not found'
      end
    end
  end

  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats/{number}' do
    operation :put do
      key :summary, 'Update chat'
      key :description, "Update chat found by its number and application token"
      key :tags, [
        'Chats'
      ]
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      parameter do
        key :name, :number
        key :in, :path
        key :description, 'number'
        key :required, true
        key :type, :integer
      end  
      response 200 do
        key :description, "Chats successfully retrieved"
      end
      response 404 do
        key :description, 'ChatApplication not found'
      end
    end
  end

  def create
    if (@chat = Chat.new(chat_params)).valid?
      chat_number = Rails.cache.redis.incr("#{params[:chat_application_token]}_chat_number")
      Sidekiq::Client.enqueue_to('high', ChatCreateWorker, params[:chat_application_token], chat_number, @chat_application.id)
      json_response({number: chat_number})
    else
      json_response({errors: @chat.errors}, :unprocessable_entity)
    end
  end

  def index
    json_response(@chat_application.chats.as_json)
  end

  def show
    json_response(@chat.as_json)
  end

  private

  def chat_params
    params.permit(:chat_application_token)
  end

  def set_chat
    if(@chat = Chat.find_by(number: params[:number], chat_application_token: params[:chat_application_token])).blank?
      json_response({error: 'Record not found'}, :not_found)
    end
  end

  def check_if_application_exists
    if (@chat_application = ChatApplication.find_by_token(params[:chat_application_token])).blank?
      json_response({error: "ChatApplication not found"}, :not_found)
    end
  end
end