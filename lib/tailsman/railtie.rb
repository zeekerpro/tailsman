module Tailsman
  class Railtie < Rails::Railtie
    class ConfigurationError < StandardError; end

    config.before_initialize do |app|
      # 在生成器环境下，设置一个空的配置对象
      if Rails.env.generator? || defined?(Rails::Generators)
        app.config.tailsman = {}
      end
    end

    # 仅在非生成器环境下初始化
    initializer "tailsman.setup", after: :load_config_initializers do |app|
      # 跳过生成器环境
      if !Rails.env.generator? && !defined?(Rails::Generators)
        begin
          # 加载配置
          app.config.tailsman = app.config_for(:tailsman)
        rescue RuntimeError => e
          # 构建友好的错误信息
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

          # 在控制台显示错误信息
          Rails.logger.error "\n\e[31m#{error_message}\e[0m"
          
          # 抛出自定义错误
          raise ConfigurationError, error_message
        end

        # 加载功能模块
        require 'tailsman/jwt_token'
        require 'tailsman/middleware'
        require 'tailsman/controller_methods'

        # 设置中间件和控制器方法
        app.config.middleware.use Tailsman::Middleware
        ActiveSupport.on_load(:action_controller) do
          include Tailsman::ControllerMethods
        end
      end
    end
  end
end
