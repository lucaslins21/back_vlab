module Types
  class QueryType < Types::BaseObject
    field :materials, [Types::MaterialType], null: false do
      argument :q, String, required: false
      argument :page, Integer, required: false
      argument :per, Integer, required: false
    end

    field :authors, [Types::AuthorType], null: false

    def materials(q: nil, page: 1, per: 20)
      Material.includes(:author).published.search(q).order(created_at: :desc).page(page).per(per)
    end

    def authors
      Author.order(:name)
    end
  end
end

