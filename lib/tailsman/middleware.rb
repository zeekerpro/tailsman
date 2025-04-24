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
        auth_header = request.headers[Tailsman::JwtToken::LABEL]
        if auth_header.present?
          # Remove token type prefix, e.g. "Bearer xxx" becomes "xxx"
          token_match = auth_header.match(/^#{Tailsman::JwtToken::TOKEN_TYPE}\s+(.+)$/i)
          token = token_match ? token_match[1] : auth_header
          
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
