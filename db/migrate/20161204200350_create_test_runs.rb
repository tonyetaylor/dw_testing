class CreateTestRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :test_runs do |t|
      t.string :title
      t.string :description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
