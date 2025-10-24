require 'rails_helper'

RSpec.describe 'Materials permissions', type: :request do
  before { host! 'localhost' }
  let!(:author) { PersonAuthor.create!(name: 'Autor', birth_date: '1990-01-01') }
  let!(:owner) { User.create!(email: 'owner@example.com', password: 'secret123') }
  let!(:other) { User.create!(email: 'other@example.com', password: 'secret123') }

  def token_for(user)
    post '/api/login', params: { email: user.email, password: 'secret123' }.to_json,
         headers: { 'CONTENT_TYPE' => 'application/json' }
    JSON.parse(response.body)['token']
  end

  it 'prevents other users from updating/destroying a material' do
    owner_token = token_for(owner)
    post '/api/materials',
         params: { material: { type: 'Video', title: 'Meu vídeo', status: 'rascunho', author_id: author.id, duration_minutes: 5 } },
         headers: { 'Authorization' => "Bearer #{owner_token}" }
    expect(response).to have_http_status(:created)
    id = JSON.parse(response.body)['id']

    other_token = token_for(other)
    patch "/api/materials/#{id}", params: { material: { title: 'Hack' } }, headers: { 'Authorization' => "Bearer #{other_token}" }
    expect(response).to have_http_status(:forbidden)

    delete "/api/materials/#{id}", headers: { 'Authorization' => "Bearer #{other_token}" }
    expect(response).to have_http_status(:forbidden)
  end

  it 'prevents viewing unpublished materials from others' do
    owner_token = token_for(owner)
    post '/api/materials',
         params: { material: { type: 'Video', title: 'Privado', status: 'rascunho', author_id: author.id, duration_minutes: 5 } },
         headers: { 'Authorization' => "Bearer #{owner_token}" }
    id = JSON.parse(response.body)['id']

    get "/api/materials/#{id}"
    expect(response).to have_http_status(:unauthorized) # exige token

    other_token = token_for(other)
    get "/api/materials/#{id}", headers: { 'Authorization' => "Bearer #{other_token}" }
    expect(response).to have_http_status(:forbidden)
  end
end
