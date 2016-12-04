class SourceTargetMapping < ApplicationRecord
	belongs_to :table
	belongs_to :test_case
end