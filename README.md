# Tailsman

Tailsman is a streamlined gem for Ruby on Rails that combines JWT authentication and CORS configuration.

## Installation

Add this line to your application's Gemfile
```ruby
gem 'tailsman', github: 'zeekerpro/tailsman'
```

and then execute
```bash
bundle install
```

After installing the gem, run the generator to set up the necessary configuration files:
```base
rails g tailsman:install
```
> use `rails g` to see all generators

This will perform the following actions:
1. Generate `app/config/tailsman.yml`, the config file used for JWT and CORS settings.
2. Generate `app/config/initializers/cors.rb`
3. Add `config.tailsman = config_for(:tailsman)` to `app/config/application.rb`


## Contributing
Edit the app/config/tailsman.yml file to specify your JWT and CORS configurations. This allows you to set up the necessary settings for JWT authentication and CORS handling in your Rails application.

## Usage
Tailsman simplifies JWT authentication and CORS configuration for your Rails application, making it easy to secure your endpoints and handle Cross-Origin Resource Sharing effectively.

### JWT Authentication
To enable JWT authentication for a specific model, include the Tailsman module in your ApplicationController:
```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include Tailsman
end

```

Then, use the `tailsman_for` class method to set up JWT authentication for the desired model.

For example, to enable JWT authentication for the User model, add the following line to your controller:

``` ruby
tailsman_for :user
```

This will generate the following methods in the controller:
* `authenticate_user`: use with a *** before_action *** to enforce authentication for specific actions.
* `current_user`: retrive the currently authenticated user.
* `sign_in(params, auth_key)`: Authenticate a user based on the provided params. The auth_key specifies the attribute name (e.g., email, phone, username) used to identify the user account.
* `force_signin(@user)`: Log in a given user instance.

Similarly, you can enable JWT authentication for the `Admin` model by adding the following line to your controller
```
tailsman_for :admin
```

This will generate the following methods in the controller: `authenticate_admin`, `current_admin`

## Contributing

Contributions to Tailsman are welcome! If you find any bugs or want to add new features, please submit an issue or pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
