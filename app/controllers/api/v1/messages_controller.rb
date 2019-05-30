class Api::V1::MessagesController < ApplicationController

  before_action :set_message, only: [:show, :update]
  before_action :check_if_chat_exists, only: [:create, :index]

  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats/{chat_number}' do
    operation :post do
      key :summary, 'Create a message'
      key :description, "Create a message to the corresponding chat"
      key :tags, [
        'Messages'
      ]
      parameter do
        key :name, :Body
        key :in, :path
        key :description, 'Body of the message'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      parameter do
        key :name, :chat_number
        key :in, :path
        key :description, 'Chat number'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "Message successfully created"
      end
      response 422 do
        key :description, 'Unprocessable entity'
      end
      response 404 do
        key :description, 'Chat not found'
      end
    end
  end

  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats/{chat_number}/messages/{number}' do
    operation :put do
      key :summary, 'Updates the message'
      key :description, "Updates the message found by chat application token, chat number and its number"
      key :tags, [
        'Messages'
      ]
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      parameter do
        key :name, :chat_number
        key :in, :path
        key :description, 'Chat number'
        key :required, true
        key :type, :integer
      end
     parameter do
        key :name, :number
        key :in, :path
        key :description, 'Message number'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :body
        key :in, :body
        schema do
          key :'$ref', :message
        end
        key :required, true
      end
      response 200 do
        key :description, 'Message successfully updated'
      end
      response 404 do
        key :description, 'Not found'
      end
    end
  end

  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats/{chat_number}/messages/{number}' do
    operation :get do
      key :summary, 'Gets the message'
      key :description, "Gets the message found by chat application token, chat number and its number"
      key :tags, [
        'Messages'
      ]
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      parameter do
        key :name, :chat_number
        key :in, :path
        key :description, 'Chat number'
        key :required, true
        key :type, :integer
      end
     parameter do
        key :name, :number
        key :in, :path
        key :description, 'Message number'
        key :required, true
        key :type, :integer
      end
      response 200 do
        key :description, 'Message successfully retrieved'
      end
      response 404 do
        key :description, 'Not found'
      end
    end
  end

  swagger_path '/api/v1/chat_applications/{chat_application_token}/chats/{chat_number}/messages' do
    operation :get do
      key :summary, 'Gets all messages or by query'
      key :description, "Gets all messages that matches the query body and returns all messages if query is not entered"
      key :tags, [
        'Messages'
      ]
      parameter do
        key :name, :chat_application_token
        key :in, :path
        key :description, 'Application token'
        key :required, true
        key :type, :string
      end  
      parameter do
        key :name, :chat_number
        key :in, :path
        key :description, 'Chat number'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :query
        key :in, :query
        key :type, :string
      end
      response 200 do
        key :description, 'Message(s) successfully retrieved'
      end
      response 404 do
        key :description, 'Not found'
      end
    end
  end


  def create
    if (@message = Message.new(message_params)).valid?
      message_number = Rails.cache.redis.incr("#{params[:chat_application_token]}_#{params[:chat_number]}_message_number")
      Sidekiq::Client.enqueue_to('high', MessageCreateOrUpdateWorker, params[:chat_application_token],
          params[:chat_number], message_number, @chat.id, 'create', params[:body])
      json_response({number: message_number})
    else
      json_response({errors: @message.errors}, :unprocessable_entity)
    end
  end

  def index
    if params[:query].nil?
      json_response(@chat.messages.order('number ASC').as_json)
    else
      json_response(@chat.messages.order('number ASC').search(params[:query]).as_json)
    end
  end

  def update
    if params[:body].present?
      Sidekiq::Client.enqueue_to('high', MessageCreateOrUpdateWorker, params[:chat_application_token], params[:chat_number],
          params[:number], 'update', params[:body])
      render status: :ok
    end
  end

  def show
    json_response({number: @message.as_json})
  end

  private

  def set_message
    if (@message =  Message.find_by(chat_application_token: params[:chat_application_token],
        chat_number: params[:chat_number], number: params[:number])).blank?
      json_response({error: 'Record not found'}, :not_found)
    end
  end

  def message_params
    params.permit(:body)
  end

   def check_if_chat_exists
    if (@chat = Chat.find_by(chat_application_token: params[:chat_application_token], number: params[:chat_number])).blank?
      json_response("Chat not found", :not_found)
    end
  end
end