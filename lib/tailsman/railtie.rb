module Tailsman
  class Railtie < Rails::Railtie
    class ConfigurationError < StandardError; end

    # Initialize configuration options
    config.tailsman = ActiveSupport::OrderedOptions.new

    config.before_initialize do |app|
      # Set empty config object in generator environment
      if Rails.env.generator? || defined?(Rails::Generators)
        app.config.tailsman ||= {}
      end
    end

    # Initialize only in non-generator environment
    initializer "tailsman.setup", after: :load_config_initializers do |app|
      # Skip generator environment
      if !Rails.env.generator? && !defined?(Rails::Generators)
        begin
          # Load configuration
          app.config.tailsman = app.config_for(:tailsman)
        rescue RuntimeError => e
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

          # Display error message in console
          Rails.logger.error "\n\e[31m#{error_message}\e[0m"
          
          # Raise custom error
          raise ConfigurationError, error_message
        end

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
end
