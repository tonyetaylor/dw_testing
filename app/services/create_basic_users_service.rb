class CreateBasicUsersService
  def call
    admin = User.find_or_create_by(email: Rails.application.secrets.admin_email) do |user|
        user.password = Rails.application.secrets.admin_password
        user.password_confirmation = Rails.application.secrets.admin_password
        user.admin!
      end

    manager = User.find_or_create_by(email: Rails.application.secrets.manager_1_email) do |user|
    	user.password = Rails.application.secrets.manager_1_password
    	user.password_confirmation = Rails.application.secrets.manager_1_password
    	user.manager!
    end

    basic_user_1 = User.find_or_create_by(email: Rails.application.secrets.basic_user_1_email) do |user|
    	user.password = Rails.application.secrets.basic_user_1_password
    	user.password_confirmation = Rails.application.secrets.basic_user_1_password
    	user.engineer!
    end

    basic_user_2 = User.find_or_create_by(email: Rails.application.secrets.basic_user_2_email) do |user|
    	user.password = Rails.application.secrets.basic_user_2_password
    	user.password_confirmation = Rails.application.secrets.basic_user_2_password
    	user.analyst!
    end
  end
end