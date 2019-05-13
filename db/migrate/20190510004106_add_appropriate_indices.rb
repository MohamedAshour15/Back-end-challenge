class AddAppropriateIndices < ActiveRecord::Migration[5.2]
  def change
    add_reference :chats, :chat_application, foreign_key: true
    add_reference :messages, :chat, foreign_key: true
    add_column :chats, :chat_application_token, :string
    add_column :messages, :chat_number, :integer
    add_column :messages, :chat_application_token, :string
    add_index :chats, [:chat_application_token, :number], unique: true
    add_index :messages, [:chat_number, :number, :chat_application_token], unique: true, name: 'message_index' 
  end
end


