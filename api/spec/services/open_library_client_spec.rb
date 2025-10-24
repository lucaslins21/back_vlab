require 'rails_helper'

RSpec.describe OpenLibraryClient do
  it 'fills book title and page_count when available' do
    isbn = '9780140328721'
    stub_request(:get, %r{https://openlibrary\.org/api/books\?bibkeys=ISBN:#{isbn}})
      .to_return(status: 200, body: {
        "ISBN:#{isbn}": {
          title: 'Fantastic Mr. Fox',
          number_of_pages: 96
        }
      }.to_json, headers: { 'Content-Type' => 'application/json' })

    book = Book.new(isbn: isbn)
    described_class.fill_book!(book)
    expect(book.title).to eq('Fantastic Mr. Fox')
    expect(book.page_count).to eq(96)
  end
end

