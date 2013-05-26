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
    service = FactoryGirl.create(:service)
    service.team.users << @user
      @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "admin")
    service
  end
  
  def addServiceWithDBList
    service = FactoryGirl.create(:service_with_dblist)
    service.team.users << @user
    @user.teamsusers.find_by_team_id(service.team.id).update_attributes(:role => "admin")
    service
  end
  
  describe "Service Settings / email lists: " do
    it "check that 'Service Settings' page loads and empty list messages appear properly when empty" do
      service = addService
      visit '/services/'+service.id.to_s+'/emaillists'

      page.should have_content "Service Settings"
      page.should have_content service.name
      page.should have_content "This service currently has no emails associated with it."
      page.should have_content "Your Black List for this service is currently empty."
      page.has_no_table? "dlist_table"
      page.has_no_table? "blist_table"
    end
    
    it "check that email lists get populated properly when corresponding database entries exist" do
      #this should add 1 blist an 1 dlist entry to the database
      service = addServiceWithDBList
      visit '/services/'+service.id.to_s+'/emaillists'

      page.should_not have_content "This service currently has no emails associated with it."
      page.should_not have_content "Your Black List for this service is currently empty."
      page.should have_content "dlist@email.com"
      page.should have_content "blist@email.com"
      page.has_table? "dlist_table"
      page.has_table? "blist_table"
    end
    
    
    it "check that add email works properly for both email lists" do
      service = addService
      visit '/services/'+service.id.to_s+'/emaillists'

      within('form#d_add') do 
        fill_in "email", :with => "dlist@add.test"
        click_button("add")
      end
      
      within('form#b_add') do 
        fill_in "email", :with => "blist@add.test"
        click_button("add")
      end
      
      page.should_not have_content "This service currently has no emails associated with it."
      page.should_not have_content "Your Black List for this service is currently empty."
      page.should have_content "dlist@add.test"
      page.should have_content "blist@add.test"
      page.has_table? "dlist_table"
      page.has_table? "blist_table"
    end
    
    
    
    it "check that remove email works properly for both email lists" do
      #this should add 1 blist an 1 dlist entry to the database
      service = addServiceWithDBList
      visit '/services/'+service.id.to_s+'/emaillists'
      
      within('#dlist_table') do 
        find("#rmbtn_0").click
      end
      
      within('#blist_table') do 
        find("#rmbtn_0").click
      end
      
      page.should have_content "This service currently has no emails associated with it."
      page.should have_content "Your Black List for this service is currently empty."
    end
    
    
    it "check that bad/incorrect email will not get added to email lists" do
      service = addService
      visit '/services/'+service.id.to_s+'/emaillists'

      within('#d_add') do 
        fill_in "email", :with => "bad@add"
        click_on("add")
      end
      
      within('#b_add') do 
        fill_in "email", :with => "bad@add"
        click_on("add")
      end
      
      page.should_not have_content "bad@add"
    end
    
    
    
    it "check that duplicate emails do not appear in the email lists" do
      service = addService
      visit '/services/'+service.id.to_s+'/emaillists'

      within('#d_add') do 
        fill_in "email", :with => "dlist@add.test"
        click_button("add")
        fill_in "email", :with => "dlist@add.test"
        click_button("add")
        
      end
      page.should have_content"The email address you are trying to add already exists in the distribution list."
      within('#b_add') do 
        fill_in "email", :with => "blist@add.test"
        click_button("add")
        fill_in "email", :with => "blist@add.test"
        click_button("add")
        
      end
        page.should have_content"The email address you are trying to add already exists in the blacklist. "
      
      #add checks here
    end
    
    
    
    it "should upload and parse csv files correctly, adding all valid emails to the blacklist" do  
      service = addService
      visit '/services/'+service.id.to_s+'/emaillists'
    
      attach_file('b_csv', 'spec/support/test_emails')
      within "form#content1" do 
        click_on("upload")
      end

      page.should have_content("csv1@email.com")
      page.should have_content("blist@email.com")

      page.all('table#blist_table tr').count.should eq 4
      
      page.should_not have_content("csv3")
      page.should_not have_content("csv4@")
      page.should_not have_content("@csv5.com")
      page.should_not have_content("csv6@@a.com")
      page.should_not have_content("!!@csv7.com")
    end
    
    
    it "should upload and parse csv files correctly, adding all valid emails to the distribution list" do  
      service = addService
      visit '/services/'+service.id.to_s+'/emaillists'
    
      within "form#content2" do   
        attach_file('d_csv', 'spec/support/test_emails')
        click_button("upload")
      end
      page.should have_content("csv1@email.com")
      page.should have_content("blist@email.com")

      page.all('table#dlist_table tr').count.should eq 4
      
      page.should_not have_content("csv3")
      page.should_not have_content("csv4@")
      page.should_not have_content("@csv5.com")
      page.should_not have_content("csv6@@a.com")
      page.should_not have_content("!!@csv7.com")
    end
    
    it "should check for invalid csv input" do
      service = addService
      visit '/services/'+service.id.to_s+'/emaillists'
    
      within "form#content2" do   
        click_button("upload")
      end
       within "form#content1" do 
        click_on("upload")
      end
      page.should have_content("There was an error while trying to process your CSV file.") 
    end
    
  end

end
