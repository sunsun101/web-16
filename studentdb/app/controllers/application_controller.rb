# frozen_string_literal: true

# Top-level superclass of all controllers
class ApplicationController < ActionController::Base
  include Pundit
end
