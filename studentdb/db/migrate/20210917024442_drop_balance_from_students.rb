# frozen_string_literal: true

# Migration to remove the "balance" field from the students table
class DropBalanceFromStudents < ActiveRecord::Migration[6.0]
  def change
    remove_column :students, :balance, :float
  end
end
