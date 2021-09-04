# frozen_string_literal: true

# Migration to add a balance field to the students table
class AddBalanceToStudents < ActiveRecord::Migration[6.0]
  def change
    add_column :students, :balance, :float
  end
end
