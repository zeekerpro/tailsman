require 'rails'

module Tailsman

  module JwtToken

    LABEL = Rails.configuration.tailsman[:label]

    SECRET_KEY = Rails.application.credentials.secret_key_base

    ALGORITHM = Rails.configuration.tailsman[:algorithm]

    LIFETIME = Rails.configuration.tailsman[:lifetime]

    VALIDITY = Rails.configuration.tailsman[:validity]

    LEEWAY = Rails.configuration.tailsman[:leeway]

    class << self
      def encode(custom_payload = {})
        jti_raw = [SECRET_KEY, Time.current.to_i].join(':').to_s
        jti = Digest::MD5.hexdigest(jti_raw)
        default_payload = {
          :iat => Time.current.to_i,
          :exp => Time.current.in(LIFETIME).to_i,
          :inv => Time.current.in(VALIDITY).to_i,
          :jti => jti
        }
        payload = default_payload.merge(custom_payload)
        JWT.encode payload, SECRET_KEY, ALGORITHM
      end

      # token 解码
      # 过期、非法等都会抛异常
      # https://github.com/jwt/ruby-jwt
      def decode(token)
        decode_data = JWT.decode(token, SECRET_KEY, true, { exp_leeway: LEEWAY, algorithm: ALGORITHM })
        HashWithIndifferentAccess.new decode_data[0]
      end

      # token 失效，需要重新分配 token
      def invalid?(token)
        Time.current.after? Time.at(decode(token)[:inv])
      end
    end

  end

end
