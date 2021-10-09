# frozen_string_literal: true

# Top-level policy
class ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    @user = user
    @record = record
  end
end
