class CreateStructures < ActiveRecord::Migration
  def change
    create_table :structures do |t|
      t.integer :kind
      t.text :name
      t.string :abbreviation
      t.text :info
      t.date :start_date
      t.date :end_date
      t.string :website

      t.timestamps
    end
  end
end
