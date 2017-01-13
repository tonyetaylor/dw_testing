class TestCase < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :test_suite, optional: true
  has_many :test_instances
  has_many :source_target_mappings
  has_many :tables, through: :source_target_mappings
end
