class CreateTrees < ActiveRecord::Migration[5.0]
  def change
    create_table :trees do |t|
      t.string :test_framework
      t.string :description
      t.string :structure_marker
      t.integer :indentation
      t.string :file_name
      t.integer :node_spec_count

      t.timestamps
    end
  end
end
