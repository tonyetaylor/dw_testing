class TestCase < ApplicationRecord
  belongs_to :user
  belongs_to :test_suite
end
