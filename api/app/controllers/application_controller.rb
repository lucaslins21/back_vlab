class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    unless token
      render json: { error: 'Token ausente' }, status: :unauthorized and return
    end

    payload = JsonWebToken.decode(token)
    @current_user = User.find(payload['sub'])
  rescue JWT::DecodeError, JWT::ExpiredSignature
    render json: { error: 'Token inválido' }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def unprocessable_entity(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end
end

