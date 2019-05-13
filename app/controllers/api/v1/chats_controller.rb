class Api::V1::ChatsController < ApplicationController

  before_action :set_chat, only: [:show, :update]
  before_action :check_if_application_exists, only: [:create]

  def create
    if Chat.new(chat_params).valid?
      chat_number = Rails.cache.redis.incr("#{params[:chat_application_token]}_chat_number")
      Sidekiq::Client.enqueue_to('high', ChatCreateWorker, params[:chat_application_token], chat_number)
      json_response({number: chat_number})
    else
      render status: :not_found
    end
  end

  def index
    json_response(Chat.where(chat_application_token: params[:chat_application_token]).as_json)
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

  def check_if_application_exists
    if ChatApplication.find_by_token(params[:chat_application_token]).blank?
      json_response("ChatApplication not found", :not_found)
    end
  end
end