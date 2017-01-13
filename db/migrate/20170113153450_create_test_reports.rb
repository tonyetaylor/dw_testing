class CreateTestReports < ActiveRecord::Migration[5.0]
  def change
    create_table :test_reports do |t|
      t.string :file_name
      t.string :test_framework

      t.timestamps
    end
  end
end
