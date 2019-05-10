class CreateChatApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_applications do |t|
      t.string :application_token
      t.string :name
      t.integer :chats_count

      t.timestamps
    end
    add_index :chat_applications, :application_token, unique: true
  end
end
