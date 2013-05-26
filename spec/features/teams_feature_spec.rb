require 'spec_helper'

describe "Teams", :type => :feature do

  before :each do
    Warden.test_mode!
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
  end
  
  after :each do
    Warden.test_reset!
  end
  
  it "no teams has been created" do
    visit '/teams'
    page.should have_content 'You do not currently hold administrator privileges with any teams.' 
  end

 it "create team 'TSET'" do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    visit '/teams'
    page.should have_content 'TEST' 
  end
 
it "create a new team" do
   visit"/teams"
   click_on"new team"
   page.should have_content "New Team"
   fill_in 'team_name',:with=>'Test'
   click_on"teamButton"
   page.should have_content "Test"

end 

it "create a new team with blank name "do
   visit"/teams"
   click_on"new team"
   page.should have_content "New Team"
   fill_in 'team_name',:with=>''
   click_on"teamButton"
   page.should have_content "Name can't be blank"

end

it "create a new team with existing name "do
   team = FactoryGirl.create(:team)
   visit"/teams"
   click_on"new team"
   page.should have_content "New Team"
   fill_in 'team_name',:with=>'TEST'
   click_on"teamButton"
   page.should have_content "Name has already been taken"

end



 it "delete team 'TEST'" do
    team = FactoryGirl.create(:team)
    #teamsuser = FactoryGirl.create(:teamsuser)
    visit '/teams'
    page.should have_content 'You do not currently hold administrator privileges with any teams.' 
  end
  
 it "team page as admin" do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    visit '/teams/2'
    page.should have_content 'Add Member' 
  end

 it "team page as member" do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:member_role)
    visit '/teams/2'
    page.should_not have_content 'Add' 
  end

  it "edit team name page" do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    visit '/teams/2/edit'
    page.should have_content 'Edit Team' 
  end

  it "redirect to team page after edit" do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    visit '/teams/2/edit'
    fill_in 'team_name', :with =>'team2'
    click_on 'teamButton'
    page.should have_content 'team2' 
  end



   it "add team member which not exists" ,:js => true do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    visit '/teams/2'
    fill_in 'email111', :with =>'chris@suncorp.com'
    click_on'addMember'
    page.driver.browser.switch_to.alert.accept
    page.should have_content 'The user does not exist' 
  end

   it "add team member which exists" ,:js => true do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    user2 = FactoryGirl.create(:user2)
    visit '/teams/2'
    fill_in 'email111', :with =>'factory.user2@test.com.au'
    click_on'addMember'
    page.driver.browser.switch_to.alert.accept
    page.should have_content 'factory.user2@test.com.au'
    
    
    fill_in 'email111', :with =>'factory.user2@test.com.au'
    click_on'addMember'
    page.driver.browser.switch_to.alert.accept
    page.should have_content 'factory.user2@test.com.au' 
    page.should have_content 'The user is already in this team'
  end

   it "delete team member" ,:js => true do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    user2 = FactoryGirl.create(:user2)
    visit '/teams/2'
    fill_in 'email111', :with =>'factory.user2@test.com.au'
    click_on'addMember'
    page.driver.browser.switch_to.alert.accept
    click_on'deleteTeam0'
    page.driver.browser.switch_to.alert.accept
    page.should_not have_content 'factory.user2@test.com.au' 
  end

   it "change team member role" ,:js => true do
    team = FactoryGirl.create(:team)
    teamsuser = FactoryGirl.create(:teamsuser)
    user2 = FactoryGirl.create(:user2)
    visit '/teams/2'
    fill_in 'email111', :with =>'factory.user2@test.com.au'
    click_on'addMember'
    page.driver.browser.switch_to.alert.accept
    page.should have_content('factory.user2@test.com.au')
    click_on'updateTeam0'
    page.driver.browser.switch_to.alert.accept
    within('#role0') do 
       page.should_not have_content('member')
    end
end
  

end







