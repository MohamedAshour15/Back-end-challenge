class Message < ApplicationRecord
  include Searchable
  belongs_to :chat
  after_create :update_messages_count
  after_destroy :update_messages_count
  validates :body, presence: true

  swagger_schema :message do
    property :body do
      key :type, :string
    end
    property :number do
      key :type, :integer
      key :minimum, 1
    end
    property :chat_application_token do
      key :type, :string
    end
    property :chat_number do
      key :type, :integer
      key :minimum, 1
    end
  end

  settings index: { number_of_shards: 1 } do
    mapping dynamic: 'false' do
      indexes :body, type: 'text', analyzer: 'ngram_analyzer', search_analyzer: 'whitespace_analyzer'
    end
  end

  def as_json(options = nil)
    super(except: [:id, :chat_id])
  end

  def as_indexed_json(options = nil)
    self.as_json( only: [:body] )
  end

  def self.search(query)
    __elasticsearch__.search({
      query: {
        bool: {
          should: [
            {
              multi_match: {
                query: query,
                fields: :body                }
            }, {
              match_phrase_prefix: {
                body: query
              }
            }
          ]
        }
      }
      }).records
  end

  def update_messages_count
    Sidekiq::Client.enqueue_to('low', MessageWorker, self.chat_id)
  end
end
Message.import force: true

