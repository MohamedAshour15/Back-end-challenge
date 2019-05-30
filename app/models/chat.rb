class Chat < ApplicationRecord
  belongs_to :chat_application
  has_many :messages, dependent: :destroy

  validates_uniqueness_of :number, scope: :chat_application_id

  after_create :update_chats_count
  after_destroy :update_chats_count

  swagger_schema :chat do
    property :number do
      key :type, :integer
      key :minimum, 1
    end
    property :chat_application_token do
      key :type, :string
    end
    property :messages_count do
      key :type, :integer
    end
  end

  def as_json(options = nil)
    super(except: [:id, :chat_application_id, :chat_application_token])
  end

  def update_chats_count
    Sidekiq::Client.enqueue_to('low', ChatWorker, self.chat_application_token)
  end
end
