class TestSuite < ApplicationRecord
	has_many :test_cases

  def to_s
  	title
  end
end
