class DropBalanceFromStudents < ActiveRecord::Migration[6.0]
  def change
    remove_column :students, :balance, :float
  end
end
