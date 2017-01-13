class AddConfluenceLinkToTestCase < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :confluence_link, :string
  end
end
