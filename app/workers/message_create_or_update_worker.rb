class MessageCreateOrUpdateWorker
  include Sidekiq::Worker

  def perform(chat_application_token, chat_number, message_number, chat_id, action, body)
    if action == 'create'
      Message.create(chat_number: chat_number, number: message_number, chat_id: chat_id, chat_application_token: chat_application_token, body: body)
    elsif (message = Message.find_by(chat_number: chat_number, number: message_number, chat_application_token: chat_application_token)).present?
      message.with_lock do 
        message.update(body: body)
      end
    end
  end
end

