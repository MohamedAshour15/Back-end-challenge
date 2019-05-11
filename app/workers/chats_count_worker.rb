class ChatsCountWorker
  include Sidekiq::Worker

  def perform(chat_application_id)
    chat_application = ChatApplication.find_by_id(chat_application_id)
    return if chat_application.nil?
    chat_application.update(chats_count: Chat.where(chat_application_id: chat_application_id).count)
  end
end 