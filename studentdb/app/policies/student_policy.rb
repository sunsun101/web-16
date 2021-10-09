# frozen_string_literal: true

# Access control policy for projects
class StudentPolicy < ApplicationPolicy
  def add_to_project?
    @user.is_admin || @user.is_student && @record[:studentid] == @user.studentid
  end
end
