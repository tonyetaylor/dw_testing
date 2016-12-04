class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.boolean :pass_flag
      t.references :user, foreign_key: true
      t.references :test_instance, foreign_key: true
      t.references :test_run, foreign_key: true
      t.references :table, foreign_key: true

      t.timestamps
    end
  end
end
