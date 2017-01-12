class AddOutputToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :output, :string
  end
end
