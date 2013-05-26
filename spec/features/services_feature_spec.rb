require 'spec_helper'

describe "SERVICES:", :type => :feature do

  before :each do
    Warden.test_mode!
    @user = FactoryGirl.create(:user)
    login_as(@user, :scope => :user)
  end
  
  after :each do
    Warden.test_reset!
  end
  
  def addService
    service = FactoryGirl.create(:service)
    service.team.users << @user
    service
  end
  
  describe "index: " do
    it "checks screen in index page when there is no service" do
      #no services screen
      visit '/services'
      page.should have_content "You don't seem to have any Services yet. Why not create one?"
      page.should_not have_content "Overview"
    end
    
    it "checks link to new service when there is no service" do
       #check link to new
      visit '/services'
      click_link 'create'
      page.should have_content "New Service"
    end
    
    it "checks screen when there is one service" do
      service = addService
      visit '/services'
      
      #at least 1 service screen
      page.should_not have_content "You don't seem to have any Services yet. Why not create one?"
      page.should have_content "Overview"
      page.should have_content service.name
    end
    
    it "checks link to single service" do
      #check link to single service
      service = addService
      visit '/services'
      
      click_link service.name
      page.should have_content service.name
      page.should have_content service.team.name
    end
    
    it "checks link to new service when there is at least one service" do
      #check link to new
      service = addService
      visit '/services'
      click_link 'new'
      page.should have_content "New Service"
      
      click_link 'Back'
      page.should have_content "Overview"
      page.should have_content service.name
    end
  end
  
  describe "new service: " do
    it "checks new service without name" do
      #no name validation check
      service = addService
      visit '/services/new'
      click_button "create service"
      page.should have_content "Name can't be blank"
    end
    
    it "check new service without team" do
      #no team validation check
      visit '/services/new'
      fill_in "serviceName", :with => "NewService"
      click_button "create service"
      page.should have_content "Team can't be blank"
      page.should_not have_content "Name can't be blank"
    end
    
    it "tests successful new service" do
      #successful service check
      service = addService
      visit '/services/new'
      fill_in "serviceName", :with => "NewService"
      fill_in "service_email_content", :with => "New service email content"
      click_button "create service"
      page.should have_content "Your service has been successfully created."
      
      newService = Service.find_by_name("NewService")
      newService.email_content.should eq("New service email content")
      newService.team.should eq(service.team)
    end
  end
  
  describe "edit service: " do
    it "ensures only admin can edit a service" do
      service = addService
      
      @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "member")
      visit '/services/'+service.id.to_s+'/edit' 
      page.should have_content "You do not have the privileges required to edit this team."
    end
    
    it "checks editing of service" do
      service = addService
      
      @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "admin")
      visit '/services/'+service.id.to_s+'/edit'
      page.should have_content "Editing Service"
      
      #check valid update
      fill_in 'serviceName', :with => "servicetestedit"
      fill_in 'service_email_content', :with => "Email Content Editted"
      click_button('update service')
      page.should have_content "Your service has been successfully updated."
      Service.find(service.id).name.should eq("servicetestedit")
      Service.find(service.id).email_content.should eq("Email Content Editted")
    end
    
    it "checks unsuccessful update and back" do
      
      service = addService
      @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "admin")
      #check invalid update
      visit '/services/'+service.id.to_s+'/edit'
      fill_in 'serviceName', :with => ""
      click_button('update service')
      page.should have_content "Name can't be blank"
      Service.find(service.id).name.should_not eq("")
      
      #check back button
      click_link "Back"
      page.should have_content service.name
      page.should have_content service.email_content
      page.should have_content service.team.name
    end
  end
  
  describe "show service: " do
    it "checks admin privileges for a service" do
      service = addService
      @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "admin")
      visit '/services/'+service.id.to_s
      page.should have_content service.name
      page.should have_content service.email_content
      page.should have_content service.team.name
      page.should have_content "Delete | Edit | Home"
      click_link("service settings")
      page.should have_content "Service Settings"
      
      #test edit/delete links
      click_link("Edit")
      page.should have_content "Editing Service"
      visit '/services/'+service.id.to_s
      click_link("Delete")
      Service.exists?(service.id).should eq(false)
    end
    
    it "checks member priveleges for a service" do
      #no delete/edit for members
      service = addService
      @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "member")
      visit '/services/'+service.id.to_s
      page.should_not have_content "Delete | Edit | Home"
      
       #test home link
      click_link("Home")
      page.should have_content "Overview"
      page.should have_content service.name
    end
    
    it "checks side navigations" do
      service = addService
      visit '/services/'+service.id.to_s
      
      #test all side navigation
      click_link("analyse")
      page.should have_content "Reports"
  
      has_link?("service settings").should eq(false)
      
      click_link("survey")
      page.should have_content "Survey"
     
      click_link("service details")
      page.should have_content service.name
      page.should have_content service.email_content  
    end
    
    it "checks EWS", :js => true do
      service = addService
      visit '/services/'+service.id.to_s
      if ENV["EWS_ENDPOINT"].present?
        click_link('select folder')
        page.should have_content "EWS Login"
   
        #incorrect username/pw
        fill_in('user_name', :with => "dummyuser")
        fill_in('password', :with => "dummypassword")
        click_button('login')
        page.should have_content "The Exchange username/password entered is incorrect. Please try again."
      else
        page.should have_content "Sorry, your administrator has not enabled Exchange Access"
      end
    end
    
    it "checks reports", :js => true do
      service = FactoryGirl.create(:service_with_results)
      service.team.users << @user
      
      service.surveys.first.results << FactoryGirl.create(:complete_promoter)
      visit '/services/'+service.id.to_s + '/report'
      
      page.should_not have_content "There are too few results received in the selected period to process the report"
      page.should have_content "GOOD"
      select(DateTime.now.strftime("%B"), :from => 'start_start_2i')
      select(DateTime.now.strftime("%Y"), :from => 'start_start_1i')
      page.should have_content "There are too few results received in the selected period to process the report"
    end
  end
  
end
