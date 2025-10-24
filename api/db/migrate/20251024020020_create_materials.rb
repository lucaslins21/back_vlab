class CreateMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :materials do |t|
      t.string :type, null: false
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: 'rascunho'
      t.references :author, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      # Specific fields for subclasses
      t.string :isbn
      t.integer :page_count
      t.string :doi
      t.integer :duration_minutes
      t.timestamps
    end

    add_index :materials, :type
    add_index :materials, :isbn, unique: true, where: 'isbn IS NOT NULL'
    add_index :materials, :doi, unique: true, where: 'doi IS NOT NULL'
  end
end

