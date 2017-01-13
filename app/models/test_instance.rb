class TestInstance < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :test_run, optional: true
  has_one :test_case
  has_one :result
end
