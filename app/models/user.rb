class User < ApplicationRecord
	has_many :test_instances
	has_many :test_cases
	has_many :test_runs
end
