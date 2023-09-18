module Tailsman
  class Railtie < Rails::Railtie

    initializer "tailsman.insert_middleware" do |app|

      app.config.tailsman = app.config_for(:tailsman)

      # must be required after app.config.tailsman is set
      # otherwise, app.config.tailsman is nil
      require('tailsman/jwt_token')

      require('tailsman/middleware')
      app.config.middleware.use Tailsman::Middleware

      require 'tailsman/controller_methods'
      ActiveSupport.on_load(:action_controller) do
        include Tailsman::ControllerMethods
      end

    end
  end
end
