class ChatCreateWorker
  include Sidekiq::Worker

  def perform(chat_application_token, chat_number, chat_application_id)
    Chat.create(chat_application_token: chat_application_token, number: chat_number, chat_application_id: chat_application_id)
  end
end

