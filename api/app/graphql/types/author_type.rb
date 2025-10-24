module Types
  class AuthorType < Types::BaseObject
    field :id, ID, null: false
    field :type, String, null: false
    field :name, String, null: false
    field :birth_date, GraphQL::Types::ISO8601Date, null: true
    field :city, String, null: true
  end
end

