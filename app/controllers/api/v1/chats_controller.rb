class Api::V1::ChatsController < ApplicationController

  before_action :set_chat, only: [:show, :update]
  before_action :check_if_application_exists, only: [:create, :index]

  def create
    if (@chat = Chat.new(chat_params)).valid?
      chat_number = Rails.cache.redis.incr("#{params[:chat_application_token]}_chat_number")
      Sidekiq::Client.enqueue_to('high', ChatCreateWorker, params[:chat_application_token], chat_number, @chat_application.id)
      json_response({number: chat_number})
    else
      json_response(errors: @chat.errors, status: :unprocessable_entity)
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