require 'json'

module Tailsman
  module Errors

    class UnauthorizedError < StandardError
      attr_reader :message, :status
      def initialize(message = "authorization failed")
        super(message)
        @message = message
        @status = :unauthorized
      end

      def serializable_hash
        instance_variables.each_with_object({}) { |var, hash|
          hash[var.to_s.delete("@")] = instance_variable_get(var)
        }
      end
    end

    class InvalidPasswordError < UnauthorizedError
      attr_reader :attribute, :status, :message
      def initialize(message = "password is invalid")
        super(message)
        @attribute = :password
      end
    end

    class NotExistError <  UnauthorizedError
      attr_reader :attribute, :status, :message
      def initialize(attribute = :email, message = "#{attribute} is not exist")
        super(message)
        @attribute = attribute
        @status = :not_found
        @message = message
      end
    end

  end
end
