class AddJiraLinkToTestCase < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :jira_link, :string
  end
end
