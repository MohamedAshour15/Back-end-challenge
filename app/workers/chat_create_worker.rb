class ChatCreateWorker
  include Sidekiq::Worker

  def perform(chat_application_token, chat_number)
    Chat.create(chat_application_token: chat_application_token, number: chat_number)
  end
end

