require 'rails/generators/base'

module Tailsman
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def registor_tailsman
        copy_file "tailsman.yml", "config/tailsman.yml"
        application "config.tailsman = config_for(:tailsman)"
      end

    end
  end
end
