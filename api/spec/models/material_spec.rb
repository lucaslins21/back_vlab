require 'rails_helper'

RSpec.describe Material, type: :model do
  let(:user) { User.create!(email: 'x@y.com', password: 'secret123') }
  let(:author) { PersonAuthor.create!(name: 'Autor', birth_date: '1990-01-01') }

  it 'validates base fields' do
    m = Material.new(title: 'AB', status: 'rascunho', author: author, user: user)
    expect(m).not_to be_valid
    m.title = 'ABC'
    expect(m).to be_valid
  end

  it 'validates Book specific fields' do
    b = Book.new(title: 'Livro', status: 'publicado', author: author, user: user, isbn: '1234567890123', page_count: 10)
    expect(b).to be_valid
    b.page_count = 0
    expect(b).not_to be_valid
  end

  it 'validates Article DOI format' do
    a = Article.new(title: 'Art', status: 'publicado', author: author, user: user, doi: '10.1000/xyz123')
    expect(a).to be_valid
    a.doi = 'bad-doi'
    expect(a).not_to be_valid
  end

  it 'validates Video duration' do
    v = Video.new(title: 'Vid', status: 'publicado', author: author, user: user, duration_minutes: 5)
    expect(v).to be_valid
    v.duration_minutes = 0
    expect(v).not_to be_valid
  end
end

