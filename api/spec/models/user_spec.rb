require 'rails_helper'

RSpec.describe User, type: :model do
  it 'validates email presence and format' do
    user = User.new(email: 'bad', password: 'secret123')
    expect(user).not_to be_valid
    user.email = 'ok@example.com'
    expect(user).to be_valid
  end

  it 'enforces password length >= 6' do
    user = User.new(email: 'a@b.com', password: '123')
    expect(user).not_to be_valid
    user.password = '123456'
    expect(user).to be_valid
  end
end

