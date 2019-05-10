class CreateChatApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_applications do |t|
      t.string :token
      t.string :name
      t.integer :chats_count, default: 0

      t.timestamps
    end
    add_index :chat_applications, :token, unique: true
  end
end
