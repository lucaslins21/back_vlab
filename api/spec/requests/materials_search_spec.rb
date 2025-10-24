require 'rails_helper'

RSpec.describe 'Materials search', type: :request do
  before { host! 'localhost' }
  let!(:user) { User.create!(email: 'user@example.com', password: 'secret123') }
  let!(:author) { PersonAuthor.create!(name: 'Autor', birth_date: '1990-01-01') }

  before do
    Material.create!(type: 'Book', title: 'Ruby on Rails Guide', status: 'publicado', author: author, user: user, isbn: '1234567890123', page_count: 10)
    Material.create!(type: 'Video', title: 'Intro to Rails', status: 'publicado', author: author, user: user, duration_minutes: 5)
  end

  it 'returns results filtered by query with pagination' do
    get '/api/materials', params: { q: 'rails', page: 1, per: 1 }
    json = JSON.parse(response.body)
    expect(json['data'].length).to eq(1)
    expect(json['pagination']['total_count']).to eq(2)
  end
end
