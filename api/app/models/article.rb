class Article < Material
  VALID_DOI = %r{\A10\.\d{4,9}/[-._;()/:A-Z0-9]+\z}i.freeze
  validates :doi, presence: true, uniqueness: true, format: { with: VALID_DOI, message: 'formato inválido' }
end

