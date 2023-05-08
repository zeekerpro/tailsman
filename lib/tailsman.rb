# frozen_string_literal: true

require_relative "tailsman/version"
require "jwt"
require "rack/cors"

module Tailsman
  extend ActiveSupport::Concern

  class UnauthorizedError < StandardError; end

  included do

    require_relative "tailsman/jwt_token"

    rescue_from JWT::DecodeError, UnauthorizedError, with: :auth_failed

    after_action :set_token

    def request_token
      request.headers[JwtToken::LABEL]
    end

    def auth_failed(error)
      Rails.logger.warn error.message
      render json: { message: error.message }, status: :unauthorized
    end

    def token_info
      JwtToken.decode request_token
    end

    private
      def set_token
        if @is_new_token_required
          Rails.logger.warn "token is invalid, dispatch a new token"
          dispatch_token
        else
          Rails.logger.info "token is valid, clean token in response headers"
          response.headers.delete_if{|key| key == JwtToken::LABEL }
        end
      end

  end

  class_methods do
    def tailsman_for(auth_model)

      # 校验 request 的token
      define_method "authenticate_#{auth_model}" do
        # 用户如果已经登录，则不用校验jwt了, 适用于微信小程序登录的情况
        # 微信小程序登录使用open_id 自动登录，在校验jwt之前校验wechat_open_id
        # 详细情况查看module WechatAuth
        raise UnauthorizedError, '请先登录' if self.send("current_#{auth_model}").nil?

      end

      # 获取当前用户
      define_method "current_#{auth_model}" do
        current_logged = instance_variable_get "@current_#{auth_model}"
        return current_logged if current_logged.present?
        return nil if request_token.nil?
        current_logged = current_from_token
        instance_variable_set("@current_#{auth_model}", current_logged)
      end

      # 从 token 解析当前用户
      define_method :current_from_token do
        token = request_token
        @is_new_token_required = JwtToken.invalid?(token)

        d_token = token_info
        current_id = d_token[:id]
        raise UnauthorizedError, '用户不存在' if (current_id.blank? or !model_constant.exists?(current_id))

        model_constant.find(current_id)
      end

      define_method :sign_in do | params, auth_key |
        current = model_constant.send("find_by_#{auth_key}", params[auth_key]).try(:authenticate, params[:password])
        raise UnauthorizedError, '用户名或密码错误' unless current

        instance_variable_set("@current_#{auth_model}", current)
        @is_new_token_required= true
      end

      # 强制登录
      define_method :force_sign_in do | current |
        instance_variable_set("@current_#{auth_model}", current )
        @is_new_token_required= true
      end

      # 转换得到当前用户的 modle
      # 'user' -> User
      # 'admin' -> Admin
      define_method :model_constant do
        auth_model.to_s.capitalize.constantize
      end

      # 为当前用户分发新的 token
      define_method :dispatch_token do
        current = send "current_#{auth_model}"
        response.headers[JwtToken::LABEL] = JwtToken.encode({ id: current[:id] }) if current
      end

      private :current_from_token, :model_constant, :dispatch_token

    end
  end

end
