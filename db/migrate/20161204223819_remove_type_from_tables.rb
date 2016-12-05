class RemoveTypeFromTables < ActiveRecord::Migration[5.0]
  def change
    remove_column :tables, :type, :string
  end
end
