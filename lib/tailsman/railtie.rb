module Tailsman
  module Configuration
    class << self
      def load_config(app)
        if installing_tailsman?
          # 只有在执行 tailsman:install 时才返回空配置
          ActiveSupport::OrderedOptions.new
        else
          # 其他所有情况都尝试加载配置
          load_from_file(app)
        end
      end

      private

      def installing_tailsman?
        defined?(Rails::Generators) && 
        defined?(Tailsman::Generators::InstallGenerator) &&
        caller.any? { |c| c.include?('tailsman/install/install_generator') }
      end

      def load_from_file(app)
        # 尝试加载配置文件
        app.config_for(:tailsman)
      rescue RuntimeError => e
        # 只有在执行 tailsman:install 时才返回空配置
        # 其他情况都抛出错误
        if installing_tailsman?
          ActiveSupport::OrderedOptions.new
        else
          # Build friendly error message
          error_message = <<~ERROR
            Tailsman configuration file not found!

            Please run the following command to generate the configuration file:
              $ rails generate tailsman:install

            Then customize the generated files:
              - config/tailsman.yml (JWT and CORS settings)
              - config/initializers/cors.rb (CORS configuration)

            For more information, visit:
              https://github.com/zeekerpro/tailsman#installation
          ERROR

          Rails.logger.error "\n\e[31m#{error_message}\e[0m"
          
          raise ConfigurationError, error_message
        end
      end
    end
  end

  class Railtie < Rails::Railtie
    class ConfigurationError < StandardError; end

    # Initialize configuration options
    config.tailsman = ActiveSupport::OrderedOptions.new

    # 添加一个早期的初始化器来加载配置
    initializer "tailsman.load_config", before: :load_config_initializers do |app|
      app.config.tailsman = Configuration.load_config(app)
    end

    # 主要的初始化器用于设置中间件和控制器方法
    initializer "tailsman.setup", after: :load_config_initializers do |app|
      # Load functionality modules
      require 'tailsman/jwt_token'
      require 'tailsman/middleware'
      require 'tailsman/controller_methods'

      # Setup middleware and controller methods
      app.config.middleware.use Tailsman::Middleware
      ActiveSupport.on_load(:action_controller) do
        include Tailsman::ControllerMethods
      end
    end
  end
end
