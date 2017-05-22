class AddVinToCars < ActiveRecord::Migration[5.1]
  def change
    add_column :cars, :vin, :string
  end
end
