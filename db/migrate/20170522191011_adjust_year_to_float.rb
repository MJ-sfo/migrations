class AdjustYearToFloat < ActiveRecord::Migration[5.1]
  def change
    change_column :cars, :year, :float 
  end
end
