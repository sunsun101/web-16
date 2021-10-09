class AddIsStudentToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_student, :boolean
  end
end
