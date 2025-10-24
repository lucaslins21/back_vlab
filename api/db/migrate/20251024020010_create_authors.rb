class CreateAuthors < ActiveRecord::Migration[7.2]
  def change
    create_table :authors do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.date :birth_date
      t.string :city
      t.timestamps
    end
    add_index :authors, :type
  end
end

