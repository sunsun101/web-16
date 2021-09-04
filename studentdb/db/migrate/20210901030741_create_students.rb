# frozen_string_literal: true

# Migration to add a students table
class CreateStudents < ActiveRecord::Migration[6.0]
  def change
    create_table :students do |t|
      t.string :name
      t.string :studentid

      t.timestamps
    end
  end
end
