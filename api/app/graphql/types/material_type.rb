module Types
  class MaterialType < Types::BaseObject
    field :id, ID, null: false
    field :type, String, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :status, String, null: false
    field :isbn, String, null: true
    field :page_count, Integer, null: true
    field :doi, String, null: true
    field :duration_minutes, Integer, null: true
    field :author, Types::AuthorType, null: false
  end
end

