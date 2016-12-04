class Result < ApplicationRecord
  belongs_to :user
  belongs_to :test_instance
  belongs_to :test_run
  belongs_to :table
end
