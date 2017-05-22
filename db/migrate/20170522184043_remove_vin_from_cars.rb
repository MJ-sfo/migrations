class RemoveVinFromCars < ActiveRecord::Migration[5.1]
  def change
    remove_column :cars, :vin, :string
  end
end
