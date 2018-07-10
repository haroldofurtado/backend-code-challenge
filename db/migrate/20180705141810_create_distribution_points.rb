class CreateDistributionPoints < ActiveRecord::Migration[5.2]
  def change
    create_table :distribution_points do |t|
      t.string :origin, null: false
      t.string :destination, null: false
      t.decimal :distance, precision: 8, scale: 2, null: false

      t.timestamps
    end

    add_index :distribution_points, [:origin, :destination], unique: true
  end
end
