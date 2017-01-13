class User < ApplicationRecord

  enum role: {
    admin: 0,
    manager: 1,
    engineer: 2,
    analyst: 3 
  }
  
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :analyst
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :invitable
	has_many :test_instances
	has_many :test_cases
	has_many :test_runs
  
  def to_s
  	email
  end
end
