class MessagesCountWorker
  include Sidekiq::Worker

  def perform(chat_application_token, chat_number)
    if (chat = Chat.find_by(chat_application_token: chat_application_token, number: chat_number)).present?
      chat.update(messages_count: Message.where(chat_application_token: chat_application_token, chat_number: chat_number).count)
    end
  end
end 