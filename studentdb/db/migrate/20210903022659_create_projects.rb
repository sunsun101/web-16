# frozen_string_literal: true

# Migration to create the projects table
class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
