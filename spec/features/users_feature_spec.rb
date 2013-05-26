require 'spec_helper'

describe "Users", :type => :feature do

  before :each do
    Warden.test_mode!
    user = FactoryGirl.create(:user2)
    login_as(user, :scope => :user)
  end
  
  after :each do
    Warden.test_reset!
  end

  it "login in to index" do
     visit '/index'
     page.should have_content'You are already signed in'
  end
  
  it "access user profile" do
    visit '/profile'
    page.should have_content 'factory.user2@test.com.au'  
  end
   
  
  it "cancle account" do
    visit '/profile'
    click_on 'cancel account'
    page.should have_content 'Your account was successfully cancelled.'  
  end

  it "change account detail successfully" do
    visit '/profile'
    fill_in 'user_current_password', :with =>'111111'
    fill_in 'user_password', :with =>'222222'
    fill_in 'user_password_confirmation', :with =>'222222'
    click_on 'update'
    page.should have_content 'Profile successfully updated'  
  end

  it "change account detail without current password" do
    visit '/profile'
    
    fill_in 'user_password', :with =>'222222'
    fill_in 'user_password_confirmation', :with =>'222221'
    click_on 'update'
    page.should have_content "Current password can't be blank"
  end
   
  it "change account detail with invalid password" do
    visit '/profile'
    fill_in 'user_current_password',:with=>'123123'
    fill_in 'user_password', :with =>'222222'
    fill_in 'user_password_confirmation', :with =>'222221'
    click_on 'update'
    page.should have_content "Current password is invalid "
  end
  
  it "change account detai without confirmation" do
    visit '/profile'
    fill_in 'user_current_password',:with=>'111111'
    fill_in 'user_password', :with =>'222222'
    fill_in 'user_password_confirmation', :with =>'222221'
    click_on 'update'
    page.should have_content "Password doesn't match confirmation"
  end

  it "change account detai with too short password" do
    visit '/profile'
    fill_in 'user_current_password',:with=>'111111'
    fill_in 'user_password', :with =>'222'
    fill_in 'user_password_confirmation', :with =>'222'
    click_on 'update'
    page.should have_content "Password is too short (minimum is 6 characters) "
  end

end

describe "User page without logged in", :type => :feature do  
  it "user register" do
    visit '/index'
    page.should have_content 'Register'
    within('div.span4.offset2.loginContainer') do 
       fill_in 'user_email', :with =>'test@suncorp.com'
       fill_in 'user_password', :with =>'222222'
       fill_in 'user_password_confirmation', :with =>'222222'
       click_on 'register'
    end
    page.should have_content 'test@suncorp.com'  
  end
  
  it "user log in with invalid pasword" do
    visit '/index'
    page.should have_content 'Log In'
    user = FactoryGirl.create(:user2)
    within('div.span4.offset1.loginContainer') do 
       fill_in 'user_email', :with =>'factory.user2@test.com.au'
       fill_in 'user_password', :with =>'222222'
       click_on 'log in'
    end
    page.should have_content 'You have entered an invalid email or password'  
  end

  it "user log in with correct pasword" do
    visit '/index'
    page.should have_content 'Log In'
    user = FactoryGirl.create(:user2)
    within('div.span4.offset1.loginContainer') do 
       fill_in 'user_email', :with =>'factory.user2@test.com.au'
       fill_in 'user_password', :with =>'111111'
       click_on 'log in'
    end
    page.should have_content 'Welcome, you have successfully signed in'  
  end

  it "forget password with incorrect email input" do
    visit '/users/password/new'
    page.should have_content 'Forgot your password'
    fill_in 'user_email', :with =>'test@suncorp.com'
    click_on 'reset password'
   
    page.should have_content 'Email not found'  
  end
end






