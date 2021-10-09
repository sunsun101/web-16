# frozen_string_literal: true

# Access control policy for projects
class ProjectPolicy < ApplicationPolicy
  def permitted_attributes
    return unless @user.is_admin

    [:name, :url, { student_ids: %i[] }, { students_attributes: %i[id studentid name _destroy _destroy_r] }]
  end

  def new?
    @user.is_admin
  end

  def update?
    @user.is_admin
  end
end
