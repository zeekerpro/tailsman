# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins 'example.com'
#
#     resource '*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

jwt_token_label = Rails.configuration.tailsman[:label]

Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins Rails.configuration.tailsman[:origins]
      resource '*',
          headers: :any,  # Allow any request headers
          expose: [ jwt_token_label, 'Content-Disposition' ].compact,  # Ensure no nil values
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          max_age: 600,
          credentials: true  # Allow sending authentication information
    end
end
