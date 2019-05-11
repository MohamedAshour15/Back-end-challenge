class Api::V1::ChatsController < ApplicationController

  before_action :set_chat, only: [:show, :update]

  def create
    chat = Chat.new(chat_params)
    chat_number = Rails.cache.redis.incr("#{params[:chat_application_token]}_chat_number")
    chat.number = chat_number
    if (chat_application = ChatApplication.find_by_token(params[:chat_application_token]))
      chat.chat_application_id = chat_application.id
    else
      render status: :not_found
      return
    end
    if chat.save
      json_response(chat.as_json)
    else
      json_response(chat.errors, :unprocessable_entity)
    end
  end

  def index
    json_response(Chat.where(chat_application_token: params[:chat_application_token]).as_json)
  end

  def update
    if @chat.update(@chat_params)
      json_response(@chat.as_json)
    else
      json_response(@chat.errors, :unprocessable_entity)
    end
  end

  def show
    if @chat.blank?
      render status: :not_found
    else
      json_response @chat.as_json
    end
  end

  private

  def chat_params
    params.permit(:chat_application_token)
  end

  def set_chat
    @chat = Chat.find_by(number: params[:number], chat_application_token: params[:chat_application_token])
  end
end