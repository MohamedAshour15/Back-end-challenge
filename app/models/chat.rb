class Chat < ApplicationRecord
  belongs_to :chat_application, foreign_key: 'chat_application_token'
  has_many :messages, dependent: :destroy

  validates_uniqueness_of :number, scope: :chat_application_id

  after_create :update_chats_count

  def as_json(options = nil)
    super(except: [:id, :chat_application_id, :chat_application_token])
  end

  def update_chats_count
    Sidekiq::Client.enqueue_to('low', ChatWorker, self.chat_application_token)
  end

  def messages
    Message.where(chat_application_token: self.chat_application_token, chat_number: self.number)
  end
end
