class TestCase < ApplicationRecord
  belongs_to :user
  belongs_to :test_suite
  has_many :test_instances
  has_many :source_target_mappings
  has_many :tables, through: :source_target_mappings
end
