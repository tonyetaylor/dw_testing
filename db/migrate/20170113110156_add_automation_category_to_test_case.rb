class AddAutomationCategoryToTestCase < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :automation_category, :integer
  end
end
