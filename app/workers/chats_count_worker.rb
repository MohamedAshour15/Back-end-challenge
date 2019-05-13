class ChatsCountWorker
  include Sidekiq::Worker

  def perform(chat_application_token)
  if (chat_application = ChatApplication.find_by_token(chat_application_token)).present?
    chat_application.update(chats_count: Chat.where(chat_application_token: chat_application_token).count)
  end
end 