class PersonAuthor < Author
  validates :name, presence: true, length: { minimum: 3, maximum: 80 }
  validates :birth_date, presence: true
  validate :birth_date_not_in_future

  private

  def birth_date_not_in_future
    return if birth_date.blank?
    errors.add(:birth_date, 'não pode ser futura') if birth_date > Date.current
  end
end

