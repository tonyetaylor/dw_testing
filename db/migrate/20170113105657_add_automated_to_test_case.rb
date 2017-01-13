class AddAutomatedToTestCase < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :automated, :boolean
  end
end
