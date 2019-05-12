class Api::V1::MessagesController < ApplicationController

  before_action :set_message, only: [:show, :update]

  def create
    message = Message.new(message_params)
    message.number = Rails.cache.redis.incr("#{params[:chat_application_token]}_#{params[:chat_number]}_message_number")
    if (chat = Chat.find_by(number: params[:chat_number], chat_application_token: params[:chat_application_token]))
      message.chat_id = chat.id
    else
      render status: :not_found
      return
    end
    if message.save
      json_response(message.as_json)
    else
      json_response(message.errors, :unprocessable_entity)
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
  end

  def show
  end

  private

  def message_params
    params.permit(:body, :chat_number)
  end

  def set_message
  end
end