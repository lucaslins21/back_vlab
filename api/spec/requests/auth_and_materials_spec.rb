require 'rails_helper'

RSpec.describe 'Auth and Materials', type: :request do
  before { host! 'localhost' }
  let!(:user) { User.create!(email: 'user@example.com', password: 'secret123') }
  let!(:author) { PersonAuthor.create!(name: 'Autor', birth_date: '1990-01-01') }

  it 'signs in and creates a material' do
    post '/api/login', params: { email: user.email, password: 'secret123' }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    # debug output if fails
    expect(response.status).to eq(200), "Body: #{response.body}"
    token = JSON.parse(response.body)['token']

    post '/api/materials',
         params: { material: { type: 'Video', title: 'Video 1', status: 'rascunho', author_id: author.id, duration_minutes: 10 } },
         headers: { 'Authorization' => "Bearer #{token}" }
    expect(response).to have_http_status(:created)
  end
end
