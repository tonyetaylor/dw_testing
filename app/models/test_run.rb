class TestRun < ApplicationRecord
  belongs_to :user, optional: true
  has_many :test_instances
end
