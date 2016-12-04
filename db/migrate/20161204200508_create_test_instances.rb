class CreateTestInstances < ActiveRecord::Migration[5.0]
  def change
    create_table :test_instances do |t|
      t.string :title
      t.string :description
      t.string :expected_result
      t.string :sql_statement
      t.references :user, foreign_key: true
      t.references :test_run, foreign_key: true

      t.timestamps
    end
  end
end
