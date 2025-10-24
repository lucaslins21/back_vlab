class Author < ApplicationRecord
  self.inheritance_column = :type

  has_many :materials, dependent: :restrict_with_error

  validates :name, presence: true, length: { minimum: 3, maximum: 120 }
end

