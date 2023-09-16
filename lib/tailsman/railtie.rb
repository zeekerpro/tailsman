require 'tailsman/middleware'
require 'tailsman/controller_methods'

module Tailsman
  class Railtie < Rails::Railtie
    initializer "tailsman.insert_middleware" do |app|
      app.config.middleware.use Tailsman::Middleware

      ActiveSupport.on_load(:action_controller) do
        include Tailsman::ControllerMethods
      end

    end
  end
end
