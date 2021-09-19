# frozen_string_literal: true

# Top-level superclass of all controllers
class ApplicationController < ActionController::Base
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = 'You attempted an unauthorized action.'
    redirect_to(request.referrer || root_path)
  end
end
