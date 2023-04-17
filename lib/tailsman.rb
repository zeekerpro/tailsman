# frozen_string_literal: true

# require "active_support/concern"
require_relative "tailsman/version"

module Tailsman
  extend ActiveSupport::Concern

  # define UnauthorizedError hierate from StandardError
  class UnauthorizedError < StandardError; end

end
