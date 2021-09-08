# frozen_string_literal: true

# Add not null constraints to projects table
class AddNotNullToProjects < ActiveRecord::Migration[6.0]
  def change
    change_column_null :projects, :name, false
    change_column_null :projects, :url, false
  end
end
