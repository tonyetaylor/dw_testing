class TestPlan < ApplicationRecord
  belongs_to :user
  has_many :test_cases
end
