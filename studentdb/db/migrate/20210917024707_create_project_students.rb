# frozen_string_literal: true

# Migration to create the project-student join table
class CreateProjectStudents < ActiveRecord::Migration[6.0]
  def change
    create_table :project_students do |t|
      t.references :project, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
  end
end
