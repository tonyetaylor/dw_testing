class AddGithubPullRequestLinkToTestCase < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :github_pull_request_link, :string
  end
end
