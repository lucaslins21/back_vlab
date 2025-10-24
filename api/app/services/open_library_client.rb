require 'net/http'
require 'json'

class OpenLibraryClient
  API_URL = 'https://openlibrary.org/api/books'

  # Fill book attributes from OpenLibrary if missing
  def self.fill_book!(book, incoming: {})
    return unless book.isbn.present?
    data = fetch_by_isbn(book.isbn)
    return if data.nil? || data.empty?
    title = data.dig('title')
    pages = data.dig('number_of_pages')

    book.title = title if book.title.blank? && title.present?
    if book.page_count.blank? && pages.to_i.positive?
      book.page_count = pages.to_i
    end
    # don't override provided fields in incoming payload
    if incoming.is_a?(Hash)
      book.title = incoming['title'] if incoming['title']
      book.page_count = incoming['page_count'] if incoming['page_count']
    end
  rescue StandardError
    # Fail silently; validations will handle missing required fields
    true
  end

  def self.fetch_by_isbn(isbn)
    url = URI("#{API_URL}?bibkeys=ISBN:#{isbn}&format=json&jscmd=data")
    res = Net::HTTP.get_response(url)
    return nil unless res.is_a?(Net::HTTPSuccess)
    json = JSON.parse(res.body)
    json["ISBN:#{isbn}"]
  end
end

