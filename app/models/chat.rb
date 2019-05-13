class Chat < ApplicationRecord
  belongs_to :chat_application
  has_many :messages, dependent: :destroy

  validates_uniqueness_of :number, scope: :chat_application_id

  after_create :update_chat_application_count

  def as_json(options = nil)
    super(except: [:id, :chat_application_id, :chat_application_token])
  end

  def update_chat_application_count
    Sidekiq::Client.enqueue_to_in('low', 15.minutes.from_now, ChatWorker, self.chat_application_token)
  end
end
