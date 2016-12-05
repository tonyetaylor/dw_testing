class AddTypeToTables < ActiveRecord::Migration[5.0]
  def change
    add_column :tables, :type, :string
  end
end
