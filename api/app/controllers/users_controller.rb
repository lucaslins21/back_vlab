class UsersController < ApplicationController
  def create
    user = User.new(user_params)
    user.save!
    render json: { id: user.id, email: user.email }, status: :created
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

