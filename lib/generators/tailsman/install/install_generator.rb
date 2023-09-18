require 'rails/generators/base'

module Tailsman
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def registor_tailsman
        template "tailsman.yml", "config/tailsman.yml"
        template "cors.rb", "config/initializers/cors.rb"
      end

    end
  end
end
