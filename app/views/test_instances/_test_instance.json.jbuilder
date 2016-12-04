json.extract! test_instance, :id, :title, :description, :expected_result, :sql_statement, :user_id, :test_run_id, :created_at, :updated_at
json.url test_instance_url(test_instance, format: :json)