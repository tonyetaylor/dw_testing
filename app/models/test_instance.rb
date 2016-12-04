class TestInstance < ApplicationRecord
  belongs_to :user
  belongs_to :test_run
end
