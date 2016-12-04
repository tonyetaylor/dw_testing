json.extract! test_case, :id, :title, :description, :expected_result, :sql_statement, :user_id, :test_suite_id, :created_at, :updated_at
json.url test_case_url(test_case, format: :json)