require 'elasticsearch/model'

class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  settings index: { number_of_shards: 1 } do
    mapping dynamic: 'false' do
      indexes :body, type: 'text', analyzer: 'english'
    end
  end
  # for auto sync model with elastic search
  #Message.import force: true

  belongs_to :chat

  def as_json(options = nil)
    super(except: [:id, :chat_id])
  end

  def as_indexed_json(options = nil)
    self.as_json( except: [ :body ] )
  end

  def self.search(query)
   __elasticsearch__.search(
   {
     query: {
        multi_match: {
          query: query,
          type: "best_fields",
          fields: ["body"]
        }
      }
   })
  end
end
