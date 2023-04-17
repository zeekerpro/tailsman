# frozen_string_literal: true

require_relative "tailsman/version"

module Tailsman
  extend AcviteSupport::Concern

  # define UnauthorizedError hierate from StandardError
  class UnauthorizedError < StandardError; end




end
