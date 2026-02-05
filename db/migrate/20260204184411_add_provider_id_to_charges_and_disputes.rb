class AddProviderIdToChargesAndDisputes < ActiveRecord::Migration[8.0]
  def change
    add_column :charges, :provider_id, :string
    add_index :charges, :provider_id, unique: true

    add_column :disputes, :provider_id, :string
    add_index :disputes, :provider_id, unique: true
  end
end
