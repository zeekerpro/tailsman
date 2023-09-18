module Tailsman
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      verify_token(env)
      @app.call(env)
    end

    private

      def verify_token(env)
        request = ActionDispatch::Request.new(env)
        token = request.headers[Tailsman::JwtToken::LABEL]
        if token.present?
          begin
            token_info = Tailsman::JwtToken.decode token
            if token_info.present?
              env[:tailsman_token_info] = token_info
              env[:tailsman_new_token_required] = Tailsman::JwtToken.invalid?(token)
            end
          rescue JWT::DecodeError => e
            # token 解析失败， 不做处理，继续执行, 交给 controller 继续处理
            # 因为有些接口不需要登录，所以不需要校验token
            # 需要登录的接口，会在 controller 中校验
            # return [401, { "Content-Type" => "text/plain" }, ["Unauthorized"]]
          end
        end
      end

  end
end
