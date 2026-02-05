class AddReopenReasonToDisputes < ActiveRecord::Migration[8.1]
  def change
    add_column :disputes, :reopen_reason, :text
  end
end
