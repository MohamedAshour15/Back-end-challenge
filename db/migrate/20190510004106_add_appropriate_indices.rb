class AddAppropriateIndices < ActiveRecord::Migration[5.2]
  def change
    add_reference :chats, :chat_application, foreign_key: true
    add_reference :messages, :chat, foreign_key: true
  end
end
