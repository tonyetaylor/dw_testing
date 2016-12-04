class TestRun < ApplicationRecord
  belongs_to :user
  has_many :test_instances
end
