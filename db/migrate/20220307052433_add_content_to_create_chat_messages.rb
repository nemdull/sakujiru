class AddContentToCreateChatMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_messages, :content, :text
  end
end
