# frozen_string_literal: true

require 'json'
require 'jwt'
require "rack/cors"
require "tailsman/version"
require "tailsman/errors"
require "tailsman/railtie" if defined?(Rails)
