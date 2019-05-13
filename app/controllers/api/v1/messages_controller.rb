class Api::V1::MessagesController < ApplicationController

  before_action :set_message, only: [:show, :update]
  before_action :check_if_chat_exists, only: [:create]

  def create
    if Message.new(message_params).valid?
      message_number = Rails.cache.redis.incr("#{params[:chat_application_token]}_#{params[:chat_number]}_message_number")
      Sidekiq::Client.enqueue_to('high', MessageCreateOrUpdateWorker, params[:chat_application_token],
          params[:chat_number], message_number, 'create', params[:body])
      json_response({number: message_number})
    else
      json_response({error: 'Record not found'}, :not_found)
    end
  end

  def index
    if params[:query].nil?
      json_response(Message.joins(:chat).where('chats.number = ?', params[:chat_number]).as_json)
    else
      json_response(Message.joins(:chat).where('chats.number = ?', params[:chat_number]).search(params[:query]).as_json)
    end
  end

  def update
    if @message && params[:body].present?
      Sidekiq::Client.enqueue_to('high', MessageCreateOrUpdateWorker, params[:chat_application_token], params[:chat_number],
          params[:number], 'update', params[:body])
      render status: :ok
    end
  end

  def show
    if @message
      json_response({number: @message.as_json})
    else
      json_response({error: 'Record not found'}, :not_found)
    end
  end

  private

  def set_message
    @message =  Message.find_by(chat_application_token: params[:chat_application_token],
        chat_number: params[:chat_number], number: params[:number])
  end

  def message_params
    params.permit(:body, :chat_application_token, :chat_number)
  end

   def check_if_chat_exists
    if Chat.find_by(chat_application_token: params[:chat_application_token], number: params[:chat_number]).blank?
      json_response("Chat not found", :not_found)
    end
  end
end