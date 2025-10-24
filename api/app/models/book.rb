class Book < Material
  validates :isbn, presence: true, uniqueness: true, length: { is: 13 }, format: { with: /\A\d{13}\z/, message: 'deve ter 13 dígitos numéricos' }
  validates :page_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
end

