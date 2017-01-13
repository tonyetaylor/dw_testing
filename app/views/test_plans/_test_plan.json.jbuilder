json.extract! test_plan, :id, :title, :sprint_begin_date, :sprint_end_date, :user_id, :notes, :created_at, :updated_at
json.url test_plan_url(test_plan, format: :json)