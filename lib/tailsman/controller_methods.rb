module Tailsman
  module ControllerMethods

    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Rescuable

      rescue_from JWT::DecodeError,
        Errors::UnauthorizedError,
        Errors::NotExistError,
        Errors::InvalidPasswordError,
        with: :auth_failed

      after_action :set_token

      def auth_failed(error)
        Rails.logger.warn error.message
        render json: { error: error.to_json }, status: :unauthorized
      end

      private
        def set_token
          if @is_new_token_required
            Rails.logger.warn "token is invalid, dispatch a new token"
            dispatch_token
          else
            Rails.logger.info "token is valid, clean token in response headers"
            response.headers.delete_if{|key| key == JwtToken::LABEL } unless response.committed?
          end
        end
    end

    class_methods do

      def tailsman_for(auth_model = :user)

        # Validate request token
        define_method "authenticate_#{auth_model}" do
          # If user is already logged in, no need to validate JWT
          # This is useful for WeChat Mini Program login scenario
          # WeChat Mini Program uses open_id for auto-login, checking wechat_open_id before JWT
          # For details, see module WechatAuth
          raise Errors::UnauthorizedError if self.send("current_#{auth_model}").nil?
        end
        alias_method :signin_required, "authenticate_#{auth_model}".to_sym

        # Get current user
        define_method "current_#{auth_model}" do
          current_logged = instance_variable_get "@current_#{auth_model}"
          return current_logged if current_logged.present?
          return nil if request.env[:tailsman_token_info].nil?
          current_logged = current_from_token
          instance_variable_set("@current_#{auth_model}", current_logged)
        end

        # Parse current user from token
        define_method :current_from_token do
          token_info = request.env[:tailsman_token_info]
          @is_new_token_required = request.env[:tailsman_new_token_required]
          current_id = token_info[:id]
          raise Errors::UnauthorizedError.new if (current_id.blank? or !model_constant.exists?(current_id))
          model_constant.find(current_id)
        end

        define_method :signin do | params, auth_key |
          current = model_constant.send("find_by_#{auth_key}", params[auth_key])
          raise Errors::NotExistError.new("#{auth_key}") unless current
          raise Errors::InvalidPasswordError.new unless current.try(:authenticate, params[:password])
          instance_variable_set("@current_#{auth_model}", current)
          @is_new_token_required= true
        end

        # Force login
        define_method :force_signin do | current |
          instance_variable_set("@current_#{auth_model}", current )
          @is_new_token_required= true
        end

        # Convert to current user's model constantize
        # 'user' -> User
        # 'admin' -> Admin
        define_method :model_constant do
          auth_model.to_s.capitalize.constantize
        end

        # Issue new token for current user
        define_method :dispatch_token do
          current = send "current_#{auth_model}"
          if current and !response.committed?
            token = JwtToken.encode({ id: current[:id] })
            response.headers[JwtToken::LABEL] = "#{JwtToken::TOKEN_TYPE} #{token}"
          end
        end

        private :current_from_token, :model_constant, :dispatch_token

      end

    end

  end
end
