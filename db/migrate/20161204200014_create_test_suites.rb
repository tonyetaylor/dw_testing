class CreateTestSuites < ActiveRecord::Migration[5.0]
  def change
    create_table :test_suites do |t|
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
