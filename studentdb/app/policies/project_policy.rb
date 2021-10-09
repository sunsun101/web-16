# frozen_string_literal: true

# Access control policy for projects
class ProjectPolicy < ApplicationPolicy
  attr_reader :user

  def permitted_attributes
    if user.is_admin
        [:name, :url, student_ids: [], students_attributes: %i[id studentid name _destroy _destroy_r]]
    else
        
    end
  end

  def add_student?(student_params)
    @user.is_admin || @user.is_student && @user.studentid == student_params[:studentid]
  end
end
