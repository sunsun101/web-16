# frozen_string_literal: true

# Prevent the same student from being added to a project multiple times
class AddUniquenessConstraintToProjectStudents < ActiveRecord::Migration[6.0]
  def change
    add_index :project_students, %i[project_id student_id], unique: true
  end
end
