require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SettingsHelper. For example:
#
# describe SettingsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ApplicationHelper do
  include Rails.application.routes.url_helpers
  
  describe "encrypt and decrypt: " do
    it "encrypt and decrypt back to the same value" do
      teststring = rand.to_s
      helper.decrypt(helper.encrypt(teststring)).should eq(teststring)
    end
    
    it "returns -1 when decrypting rubbish" do
      teststring = rand.to_s
      helper.decrypt(teststring).should eq(-1)
    end
    
    it "encrypts a value" do
      teststring = rand.to_s
      teststring.should_not eq(helper.encrypt(teststring))
    end
  end
  
  describe "check if admin: " do
    #before { pending "current_user not working" }
    
    it "checks a admin" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
      
      current_user = user
      team = FactoryGirl.create(:team)
      team.users << current_user
      
      current_user.teamsusers.find_by_team_id(team.id).update_attributes(:role => "admin")
      helper.is_team_admin(team).should eq(true)
    end
    
    it "checks a member" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
      
      current_user = user
      team = FactoryGirl.create(:team)
      team.users << current_user
      
      current_user.teamsusers.find_by_team_id(team.id).update_attributes(:role => "member")
      helper.is_team_admin(team).should eq(false)
    end
  end
end
