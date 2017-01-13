class RemoveSqlStatementFromTestCase < ActiveRecord::Migration[5.0]
  def change
    remove_column :test_cases, :sql_statement, :string
  end
end
