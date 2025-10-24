class Material < ApplicationRecord
  STATUSES = %w[rascunho publicado arquivado].freeze

  self.inheritance_column = :type

  belongs_to :author
  belongs_to :user

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :author, presence: true
  validates :user, presence: true

  scope :published, -> { where(status: 'publicado') }

  def self.search(query)
    return all if query.blank?
    q = "%#{sanitize_sql_like(query)}%"
    joins(:author).where('materials.title ILIKE :q OR materials.description ILIKE :q OR authors.name ILIKE :q', q: q)
  end
end

