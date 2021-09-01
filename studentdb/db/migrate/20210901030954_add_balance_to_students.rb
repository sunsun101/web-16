class AddBalanceToStudents < ActiveRecord::Migration[6.0]
  def change
    add_column :students, :balance, :float
  end
end
