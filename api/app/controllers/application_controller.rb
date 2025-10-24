class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    unless token
      render json: { error: 'Token ausente' }, status: :unauthorized
      return false
    end

    payload = JsonWebToken.decode(token)
    @current_user = User.find(payload['sub'])
    true
  rescue JWT::DecodeError, JWT::ExpiredSignature
    render json: { error: 'Token inválido' }, status: :unauthorized
    false
  end

  # Optional authentication for endpoints where token is not required
  def maybe_authenticate
    token = request.headers['Authorization']&.split(' ')&.last
    return if token.blank?
    payload = JsonWebToken.decode(token)
    @current_user = User.find_by(id: payload['sub'])
  rescue StandardError
    @current_user = nil
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
