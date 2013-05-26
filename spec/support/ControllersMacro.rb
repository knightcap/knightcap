include Warden::Test::Helpers

module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(:admin) # Using factory girl as an example
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
    end
  end
  
  def log_in
    Warden.test_mode!
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
  end
  
  def reset_log_in
    Warden.test_reset!
  end
  
end