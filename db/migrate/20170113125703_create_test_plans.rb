class CreateTestPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :test_plans do |t|
      t.string :title
      t.date :sprint_begin_date
      t.date :sprint_end_date
      t.references :user, foreign_key: true
      t.string :notes

      t.timestamps
    end
  end
end
