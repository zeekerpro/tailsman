# Tailsman

Tailsman is an elegantly crafted Ruby on Rails gem designed to seamlessly integrate JWT authentication and CORS configuration into your application.

## Installation

To get started, add Tailsman to your application's Gemfile:
```ruby
gem 'tailsman', github: 'zeekerpro/tailsman'
```

Then, install the gem by running:
```bash
bundle install
```

Next, use the provided generator to set up the essential configuration files:
```base
rails g tailsman:install
```
> Tip: Run rails g to explore all available generators.

Executing this command will:
1. Create app/config/tailsman.yml, a configuration file for JWT and CORS settings.
2. Generate `app/config/initializers/cors.rb`
3. Automatically include the Tailsman::ControllerMethods module in ActionController::Base.

## configurations
Customize your JWT and CORS settings by editing the app/config/tailsman.yml file. This configuration step is crucial for tailoring JWT authentication and CORS management to your application's specific needs.


## Usage
Tailsman streamlines the integration of JWT authentication and CORS configuration into your Rails application. Its intuitive design simplifies securing your endpoints and effectively managing Cross-Origin Resource Sharing.

### JWT Authentication

Use the `tailsman_for` class method to enable JWT authentication for your desired model.

For instance, to set up JWT authentication for the User model, insert this line into your controller:
``` ruby
tailsman_for :user
```

This addition dynamically generates several controller methods:

* `authenticate_user` and its alias `signin_required`: Designed for use with `before_action`, these methods enforce authentication for specific actions. `signin_required` serves as a straightforward alias for `authenticate_user`.
* `current_user`: Retrieve the currently authenticated user.
* `sign_in(params, auth_key)`: Authenticate a user based on provided parameters. The `auth_key` identifies the user account attribute (like email, phone, or username).
* `force_signin(@user)`: Directly log in a specified user instance.

Moreover, `signin_required` is defined as an alias for `authenticate_user`, offering a uniform and intuitive naming convention across your controllers.

To apply JWT authentication to the `Admin` model, add this line:

```ruby
tailsman_for :admin
```

This will generate `authenticate_admin`, `signin_required`, and `current_admin` methods, mirroring the User model's authentication capabilities.

## Contributing

We warmly welcome contributions to Tailsman! Whether it's bug reports or feature requests, feel free to submit an issue or a pull request.

## License

Tailsman is open source, available under the [MIT License](https://opensource.org/licenses/MIT).

