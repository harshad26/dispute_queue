class CreateCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :charges do |t|
      t.integer :amount_cents
      t.string :currency
      t.string :customer_email
      t.string :status

      t.timestamps
    end
  end
end
