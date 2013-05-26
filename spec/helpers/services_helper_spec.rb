require 'spec_helper'

describe ServicesHelper do

  #test for get score
  describe "get score: " do
    it "calculate neutral score" do
      service = FactoryGirl.create(:service_with_results)
      helper.get_score(service).should eq(0)
    end
    
    it "calculate positive score" do
      service = FactoryGirl.create(:service_with_results)
      survey = FactoryGirl.create(:dummy_survey)
      service.surveys << survey
      survey.results << FactoryGirl.create(:promoter_now)
      helper.get_score(service).should eq(100)
    end
    
    it "calculate negative score" do
      service = FactoryGirl.create(:service_with_results)
      survey = FactoryGirl.create(:dummy_survey)
      service.surveys << survey
      survey.results << FactoryGirl.create(:detractor_now)
      helper.get_score(service).should eq(-100)
    end
    
    it "calculates random score" do
      #add random number of p_d_n and get results
      promoters = rand(100)
      detractors = rand(100)
      neutrals = rand(100)
    
      service = FactoryGirl.create(:service_with_results)
      survey = service.surveys.first
      
      for i in 1..promoters
        survey.results << FactoryGirl.create(:promoter_now)
      end
      
      for i in 1..neutrals
        survey.results << FactoryGirl.create(:neutral_now)
      end
      
      for i in 1..detractors
         survey.results << FactoryGirl.create(:detractor_now)
      end
      
      #calculate according to random
      expectedResult = ((promoters - detractors).to_f/(promoters+detractors+neutrals) * 100).round()
      survey.results.length.should eq(promoters+detractors+neutrals)
      helper.get_score(service).should eq(expectedResult)
    end
  end
  
  #tests for get_trend and trend_style
  describe "trends: " do
    it "get no trend" do
      service = FactoryGirl.create(:service_with_results)
      survey = service.surveys.first
      helper.get_trend(service).should eq(1)
      helper.trend_style(service).should eq(57)
    end
    
    it "get uptrend" do
      service = FactoryGirl.create(:service_with_results)
      survey = service.surveys.first
      survey.results << FactoryGirl.create(:promoter_now)
      helper.get_trend(service).should eq(0)
      helper.trend_style(service).should eq(0)
    end

    it "get downtrend" do
      service = FactoryGirl.create(:service_with_results)
      survey = service.surveys.first
      survey.results << FactoryGirl.create(:promoter_one_month_ago)
      result = FactoryGirl.create(:promoter_one_month_ago)
      helper.get_trend(service).should eq(2)
      helper.trend_style(service).should eq(114)
    end
  end
  
  describe "myteamselect: " do
    it "returns team if not nil" do
      service = FactoryGirl.create(:service_with_results)
      helper.myTeamSelect(service, service.team).should eq(service.team)
    end
    
    it "returns team id if myTeam = nil" do
      service = FactoryGirl.create(:service_with_results)
      helper.myTeamSelect(service, nil).should eq(service.team.id)
    end
    
    it "returns blank if service does not have team" do
      service = FactoryGirl.create(:service_with_results)
      service.team = nil
      helper.myTeamSelect(service, nil).should eq("")
    end
  end
  
  describe "check service admin" do
    
    it "checks if user is a admin of the team the service belong to" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
      current_user = user
      
      service = FactoryGirl.create(:service_with_results)
      team = service.team
      team.users << current_user
      
      current_user.teamsusers.find_by_team_id(team.id).update_attributes(:role => "admin")
      helper.checkServiceAdmin(service).should eq(true)
      
      current_user.teamsusers.find_by_team_id(team.id).update_attributes(:role => "member")
      helper.checkServiceAdmin(service).should eq(false)
    end
    
    it "checks if user belong to the team the service belong to" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
      current_user = user
      
      service = FactoryGirl.create(:service_with_results)
      team = service.team
      helper.checkService(service).should eq(false)
      
      team.users << current_user
      helper.checkService(service).should eq(true)
    end
  end
end
  