class AddMessagesCountToChats < ActiveRecord::Migration[5.2]
  def change
    add_column :chats, :messages_count, :integer, default: 0
  end
end
