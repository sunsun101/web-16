# frozen_string_literal: true

# Add a role field is_admin to users table
class AddIsAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_admin, :boolean, default: false
  end
end
