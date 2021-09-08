# frozen_string_literal: true

# Top-level site controller
class SiteController < ApplicationController
  def index; end

  def admin_dashboard
    authorize :site, :admin_dashboard?
  end
end
