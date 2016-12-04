class Table < ApplicationRecord
	has_many :test_cases
	has_many :source_target_mappings
	has_many :test_cases, through: :source_target_mappings
end
