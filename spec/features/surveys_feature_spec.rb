require 'spec_helper'

describe "Surveys:", :type => :feature do

  before :each do
    Warden.test_mode!
    @user = FactoryGirl.create(:user)
    login_as(@user, :scope => :user)
  end
  
  after :each do
    Warden.test_reset!
  end
  
  def addService
    service = FactoryGirl.create(:service_with_dblist)
    service.team.users << @user
    service
  end
  
  describe "survey index general: " do
    it "checks that survey page is prepared properly with no emails in the list" do
      service = FactoryGirl.create(:service)
      service.team.users << @user
      visit '/services/'+service.id.to_s+'/survey?refresh=true'

      page.should have_content "Survey"
      page.should have_content service.name
      page.should have_content "Please enter any email addresses you wish to send this survey to."
      page.has_table? "email_list"
      page.should_not have_content "Send"
      page.should_not have_content "Add to Black List"
    end
    
    it "checks that emails from dlist are automatically loaded and the email list table appears properly in surveys page" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'

      page.should_not have_content "Please enter any email addresses you wish to send this survey to."
      page.should have_content service.dlists.first.email
    end
    
    it "checks that only admins can add to blacklist" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
      page.should_not have_content "Add to Black List"
      
      @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "admin")
      
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
      page.should have_content "Add to Black List"
      
    end
    
    it "should be able to delete emails", :js => true do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
      page.should have_content service.dlists.first.email
      find("#btnRemove0").click
      page.should_not have_content service.dlists.first.email
    end
  end
  
  
  describe "add email: ", :js => true do
    it "checks that emails are added properly" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
    
      fill_in "email_email", :with => "email@test.test"
      click_on("add email")

      page.should have_content "email@test.test"
      page.should_not have_content "You don't seem to have any Services yet. Why not create one?"
    end
    
    it "checks that duplicate entries don't get added to the list" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'

      fill_in "email_email", :with => "email@test.test"
      click_button("add email")
      fill_in "email_email", :with => "email@test.test"
      click_button("add email")
      page.driver.browser.switch_to.alert.accept
      find("#btnRemove1")
      expect { find("#btnRemove2") }.to raise_error
    end
    
    it "checks that blacklisted entries don't get added to the list" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
      
      fill_in "email_email", :with => "blist@email.com"
      click_button("add email")
      page.driver.browser.switch_to.alert.accept
      page.should_not have_content "blist@email.com"
    end
    
    it "should validate email regex" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
    
      fill_in "email_email", :with => "emailtest1"
      click_on("add email")
      page.driver.browser.switch_to.alert.accept
      page.should_not have_content "emailtest1"
      
      fill_in "email_email", :with => "emailtest2@"
      click_on("add email")
      page.driver.browser.switch_to.alert.accept
      page.should_not have_content "emailtest2@"
      
      fill_in "email_email", :with => "emailtest3@@a.com"
      click_on("add email")
      page.driver.browser.switch_to.alert.accept
      page.should_not have_content "emailtest3@@a.com"
      
      fill_in "email_email", :with => "@emailtest4.com"
      click_on("add email")
      page.driver.browser.switch_to.alert.accept
      page.should_not have_content "@emailtest4.com"
      
      fill_in "email_email", :with => "!!@emailtest5.com"
      click_on("add email")
      page.driver.browser.switch_to.alert.accept
      page.should_not have_content "@emailtest5.com"
    end
  end

  describe "import csv: " do
    it "should upload a csv and parse it's values" do  
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
    
      attach_file('csvfile', 'spec/support/test_emails')
      click_button("upload")

      page.should have_content("csv1@email.com")
    end
    
    it "should process invalid csv files" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
    
      click_button("upload")
      page.should have_content "There was an error while trying to process your CSV file."
    end
    
    it "should ignore values in blacklists" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
    
      attach_file('csvfile', 'spec/support/test_emails')
      click_button("upload")

      page.should_not have_content("blist@email.com")
    end
    
    it "should only add one instance of repeated e-mails" do
      service = FactoryGirl.create(:service)
      service.team.users << @user
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
    
      attach_file('csvfile', 'spec/support/test_emails')
      click_button("upload")

      page.should have_content("csv2@email.com")
      page.all('table#email_list tr').count.should eq 4
    end

    it "should check email regex" do
      service = addService
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
    
      attach_file('csvfile', 'spec/support/test_emails')
      click_button("upload")

      page.should_not have_content("csv3")
      page.should_not have_content("csv4@")
      page.should_not have_content("@csv5.com")
      page.should_not have_content("csv6@@a.com")
      page.should_not have_content("!!@csv7.com")
    end
  end
  
  describe "sending of email: ", :js => true do
    it "should be able to send e-mails" do
      service = FactoryGirl.create(:service)
      service.team.users << @user
      visit '/services/'+service.id.to_s+'/survey?refresh=true'
      
      
      fill_in "email_email", :with => "test@sendmail.com"
      click_button("add email")
      click_button("send")
      
      Delayed::Worker.new.work_off
      ActionMailer::Base.deliveries.last.to.should include("test@sendmail.com")
    end
  end 
end
