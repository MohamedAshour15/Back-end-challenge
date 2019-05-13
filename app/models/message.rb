class Message < ApplicationRecord
  include Searchable
  belongs_to :chat

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
end
