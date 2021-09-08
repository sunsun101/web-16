# frozen_string_literal: true

# Policy for admin access
class SitePolicy
  attr_reader :user

  def initialize(user, _)
    @user = user
  end

  def admin_dashboard?
    user.is_admin
  end
end
