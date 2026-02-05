class CreateWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_events do |t|
      t.string :event_type
      t.string :external_id
      t.jsonb :payload
      t.datetime :processed_at

      t.timestamps
    end
    add_index :webhook_events, :external_id, unique: true
  end
end
