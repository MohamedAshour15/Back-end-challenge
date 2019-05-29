class MessagesCountWorker
  include Sidekiq::Worker

  def perform(chat_id)
    if (chat = Chat.find_by_id(chat_id)).present?
      chat.update(messages_count: chat.messages.count)
    end
  end
end 