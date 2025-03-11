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
            # Token parsing failed, continue execution and let controller handle it
            # Some endpoints don't require login, so token validation is not needed
            # For endpoints requiring login, validation will be done in controller
            # return [401, { "Content-Type" => "text/plain" }, ["Unauthorized"]]
          end
        end
      end

  end
end
