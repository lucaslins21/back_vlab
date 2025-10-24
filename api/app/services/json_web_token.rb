require 'jwt'

class JsonWebToken
  class << self
    def encode(payload, exp: 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret_key, 'HS256')
    end

    def decode(token)
      body, = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
      body
    end

    def secret_key
      ENV.fetch('JWT_SECRET', 'dev-secret-change-me')
    end
  end
end

