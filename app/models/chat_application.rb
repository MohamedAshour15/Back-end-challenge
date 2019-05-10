class ChatApplication < ApplicationRecord
  has_secure_token :application_token
  has_many :chats, dependent: :destroy
end
