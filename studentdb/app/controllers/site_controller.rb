# frozen_string_literal: true

# Top-level site controller
class SiteController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index; end

  def admin_dashboard
    authorize :site, :admin_dashboard?
  end
end
