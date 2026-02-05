class CreateDisputes < ActiveRecord::Migration[8.1]
  def change
    create_table :disputes do |t|
      t.references :charge, null: false, foreign_key: true
      t.integer :amount_cents
      t.integer :status

      t.timestamps
    end
  end
end
