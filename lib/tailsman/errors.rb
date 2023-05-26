require 'json'

module Tailsman
  module Errors

    class UnauthorizedError < StandardError
      attr_reader :message, :status
      def initialize(message = "登录失败")
        super(message)
        @message = message
        @status = :unauthorized
      end

      def to_json
        instance_variables.each_with_object({}) { |var, hash|
          hash[var.to_s.delete("@")] = instance_variable_get(var)
        }.to_json
      end
    end

    class InvalidPasswordError < UnauthorizedError
      attr_reader :attribute, :status, :message
      def initialize(message = "密码错误")
        super(message)
        @attribute = :password
      end
    end

    class NotExistError <  UnauthorizedError
      attr_reader :attribute, :status, :message
      def initialize(attribute = :email, message = "用户不存在")
        super(message)
        @attribute = attribute
        @status = :not_found
        @message = message
      end
    end

  end
end
