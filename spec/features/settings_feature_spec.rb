require 'spec_helper'

  def create_user(role)
    
    Warden.test_mode!
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user) 
    
    admin = FactoryGirl.create(:admin_role)
    member = FactoryGirl.create(:member_role)
    
    role == "Admin"? admin.users << user : member.users << user
    user
  end
  
#tests if permissions are correctly intrepreted in settings page
describe "SETTINGS:", :type => :feature do
  after :each do
    Warden.test_reset!
  end
  
  describe "edit profile: " do
    #settings page should allow all users to edit their own profile
    it "should be able to edit profile" do
      user = create_user("TeamMember")
      
      visit '/settings'
      page.should have_content 'Edit Profile'
      click_link('Edit Profile')
      page.should have_content "Change Account Details"
    end
  end   
  
  describe "widget settings: " do
    #if they were a team member, they should be able to see widget settings
    it "should be able to see widget settings if member" do
      user = create_user("TeamMember")
      visit '/settings'
      
      page.should have_content "Widget Setting"
      page.should_not have_content "Add User"
    end
    
    #swapping of widgets check
    it "should be able to view widgets" do
      create_user("TeamMember")
      visit '/settings'
      
      #find widget swap buttons
      find('#swap0').visible?
      find('#swap1').visible?
      find('#swap2').visible?
  
      #default value to be displayed
      expect(find('#widgets0').text).to eq("Responses")
      expect(find('#widgetstep0').text).to eq("Monthly")
      expect(find('#widgets1').text).to eq("Promoters")
      expect(find('#widgetstep1').text).to eq("Monthly")
      expect(find('#widgets2').text).to eq("Detractors")
      expect(find('#widgetstep2').text).to eq("Monthly")
    end
  
     it "should be able to swap widgets", :js => true do
      user = create_user("TeamMember")
      visit '/settings'
      
      #swap widgets0
      find('#swap0').click
      page.should have_content "Edit Widget" #pop up works
      select('Promoters', :from => 'widgets_widgets')
      select('Daily', :from => 'date_step')
      click_button("confirm")
      expect(find('#widgets0').text).to eq("Promoters")
      expect(find('#widgetstep0').text).to eq("Daily")
      
      #swap widgets1
      find('#swap1').click
      page.should have_content "Edit Widget" #pop up works
      select('Neutrals', :from => 'widgets_widgets')
      select('Yearly', :from => 'date_step')
      click_button("confirm")
      expect(find('#widgets1').text).to eq("Neutrals")
      expect(find('#widgetstep1').text).to eq("Yearly")
      
      service = FactoryGirl.create(:service)
      service.team.users << user
      
      visit '/services'
      page.should have_content("Promoters: Daily")
      page.should have_content("Neutrals: Yearly")
      
    end
  end
  
  describe "admin settings: " do
    #if they were a admin, they should be able to add members
    it "should be able to see admin settings if admin" do
      create_user("Admin")
      visit '/settings'
      
      page.should_not have_content "Widget Setting"
      page.should have_content "Add User"
  
    end
  
    #admin settings check
    it "should be able to register other users" do
      create_user("Admin")
      new_team = FactoryGirl.create(:team)
      visit '/settings'
      
      #create user test@yopmail.com
      fill_in("new_user_email", :with => "test@yopmail.com")
      select('TeamMember', :from => 'new_user_role')
      select(new_team.name, :from => 'new_user_team')
      click_button('create user')
      #successful notice
      page.should have_content "User test@yopmail.com successfully created."
      #role set correctly
      (User.find_by_email("test@yopmail.com").role?:team_member).should eq(true)
      (User.find_by_email("test@yopmail.com").teams.include? new_team).should eq(true)
  
      #create wrong user
      fill_in("new_user_email", :with => "test@yopmail.com")
      select('Admin', :from => 'new_user_role')
      select(new_team.name, :from => 'new_user_team')
      click_button('create user')
      page.should have_content "User test@yopmail.com already exists."
      (User.find_by_email("test@yopmail.com").role?:admin).should eq(false)
    end

   it "access to global black list admin page" do
      create_user("Admin")
      visit '/settings/blist'
      page.should have_content "Global Black List"
      fill_in "email",:with=>"a@b.com"
      click_on 'add'
      page.should have_content 'a@b.com'  
   end
   
   it "add emails to blist via csv file without choosing a file" do
      create_user("Admin")
      visit '/settings/blist'
      page.should have_content "Global Black List"
      click_on 'upload'
      page.should have_content 'There was an error while trying to process your CSV file. '  
   end

   it "remove from black list" do
      create_user("Admin")
      visit '/settings/blist'
      page.should have_content "Global Black List"
      fill_in "email",:with=>"a@b.com"
      click_on 'add'
      page.should have_content 'a@b.com'
      find("#rmbtn_0").click
      page.should_not have_content 'a@b.com'
    end

  end
end




