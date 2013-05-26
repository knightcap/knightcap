require 'spec_helper'

describe ReportsHelper do
  
  before :each do
      @service = FactoryGirl.create(:service_with_results)
      @survey = @service.surveys.first
  end
  
  describe "count responses test: " do
    it "should count responses" do
      @survey.results << FactoryGirl.create(:detractor_now)
      helper.count_responses(DateTime.now - 2.days, DateTime.now).should eq(1)
    end
    
    it "should skip responses that are not done" do
      @survey.results << FactoryGirl.create(:new_result)
      @survey.results << FactoryGirl.create(:detractor_now)
      helper.count_responses(DateTime.now - 2.days, DateTime.now).should eq(1)
    end
    
    it "should count responses according to date" do
      @survey.results << FactoryGirl.create(:detractor_one_month_ago)
      @survey.results << FactoryGirl.create(:detractor_now)
      helper.count_responses(DateTime.now - 2.days, DateTime.now).should eq(1)
      helper.count_responses(DateTime.now - 1.months - 2.days, DateTime.now).should eq(2)
    end
  end
  
  describe "pdn chart test: " do
    it "should return a hashtable of int and array" do
      answer = helper.get_pdn_values(DateTime.now - 2.days, DateTime.now)
      expected = Hash.new
      expected["count"] = 0
      expected["pdn"] = [0,0,0]
      answer.should eq(expected)
    end
    
    it "should count promoters, detractors, and neutrals" do
      
      survey = @survey
      randomAmount = rand(10) + 5
      
      #n neutrals, n+1 detractors, n+2 promoter
      for i in 1..randomAmount
        survey.results << FactoryGirl.create(:promoter_now)
        survey.results << FactoryGirl.create(:neutral_now)
        survey.results << FactoryGirl.create(:detractor_now)
      end
      
      survey.results << FactoryGirl.create(:detractor_now)
      survey.results << FactoryGirl.create(:promoter_now)
      survey.results << FactoryGirl.create(:promoter_now)
      
      
      answer = helper.get_pdn_values(DateTime.now - 2.days, DateTime.now)
      expected = Hash.new
      expected["count"] = randomAmount + 2
      expected["pdn"] = [randomAmount+2,randomAmount, randomAmount+1]
      answer.should eq(expected)
    end
    
    it "should not count not_done results and results out of range" do
      
      survey = @survey
      randomAmount = rand(10) + 5
      
      #n neutrals, n+1 detractors, n+2 promoter
      for i in 1..randomAmount
        survey.results << FactoryGirl.create(:promoter_now)
        survey.results << FactoryGirl.create(:neutral_now)
        survey.results << FactoryGirl.create(:detractor_now)
      end
      
      survey.results << FactoryGirl.create(:detractor_now)
      survey.results << FactoryGirl.create(:promoter_now)
      survey.results << FactoryGirl.create(:promoter_now)
      
      survey.results << FactoryGirl.create(:new_result)
      survey.results << FactoryGirl.create(:promoter_one_month_ago)
      
      answer = helper.get_pdn_values(DateTime.now - 2.days, DateTime.now)
      expected = Hash.new
      expected["count"] = randomAmount + 2
      expected["pdn"] = [randomAmount+2,randomAmount, randomAmount+1]
      answer.should eq(expected)
      
      answer = helper.get_pdn_values(DateTime.now - 1.months - 1.days, DateTime.now)
      expected["count"] = randomAmount + 3
      expected["pdn"] = [randomAmount+3,randomAmount, randomAmount+1]
      answer.should eq(expected)
    end
  end
  
  describe "word chart tests: " do
    it "should return an empty hash" do
      answer = helper.get_words_used(DateTime.now - 2.days, DateTime.now)
      expected = Hash.new
      expected.should eq(answer)
    end
    
    it "should count words" do
      @survey.results << FactoryGirl.create(:useful_comments)
      answer = helper.get_words_used(DateTime.now - 2.days, DateTime.now)
      expected = Hash.new
      expected["AWESOME"] = 3
      expected["GREAT"] = 3
      expected["GOOD"] = 2
      
      answer.should eq(expected)
    end
    
    it "should strip common words" do
      @survey.results << FactoryGirl.create(:useful_comments)
      @survey.results << FactoryGirl.create(:useless_comments)
      @survey.results << FactoryGirl.create(:useful_comments)
      answer = helper.get_words_used(DateTime.now - 2.days, DateTime.now)
      expected = Hash.new
      expected["AWESOME"] = 6
      expected["GREAT"] = 6
      expected["GOOD"] = 4
      
      answer.should eq(expected)
    end
    
    it "should check time range and if survey is" do
      @survey.results << FactoryGirl.create(:useful_comments)
      @survey.results << FactoryGirl.create(:new_result)
      @survey.results << FactoryGirl.create(:useful_one_month_ago)
      answer = helper.get_words_used(DateTime.now - 2.days, DateTime.now)
      expected = Hash.new
      expected["AWESOME"] = 3
      expected["GREAT"] = 3
      expected["GOOD"] = 2
      
      answer.should eq(expected)
      
      answer = helper.get_words_used(DateTime.now - 1.months-1.days, DateTime.now)
      expected = Hash.new
      expected["AWESOME"] = 6
      expected["GREAT"] = 6
      expected["GOOD"] = 4
      
      answer.should eq(expected)
    end
  end
  
  describe "responses test: " do
    it "should return a hashtable of hashtable" do
      answer = helper.get_nps_response(DateTime.now - 2.days, DateTime.now, "Months")
      expected = Hash.new
      expected[DateTime.now.strftime("%b %y")] = Hash.new
      expected[DateTime.now.strftime("%b %y")]["promoters"] = 0
      expected[DateTime.now.strftime("%b %y")]["neutrals"] = 0
      expected[DateTime.now.strftime("%b %y")]["detractors"] = 0
      expected[DateTime.now.strftime("%b %y")]["average"] = 0
      
      
      answer.should eq(expected)
    end
    
    it "should count the promoters, neutrals, and detractors and average" do
      survey = @survey
      randomAmount = rand(10) + 5
      
      #n neutrals, n+1 detractors, n+2 promoter
      for i in 1..randomAmount
        survey.results << FactoryGirl.create(:promoter_now)
        survey.results << FactoryGirl.create(:neutral_now)
        survey.results << FactoryGirl.create(:detractor_now)
      end
      
      survey.results << FactoryGirl.create(:detractor_now)
      survey.results << FactoryGirl.create(:promoter_now)
      survey.results << FactoryGirl.create(:promoter_now)
      expected = Hash.new
      expected[DateTime.now.strftime("%b %y")] = Hash.new
      expected[DateTime.now.strftime("%b %y")]["promoters"] = randomAmount + 2
      expected[DateTime.now.strftime("%b %y")]["neutrals"] = randomAmount
      expected[DateTime.now.strftime("%b %y")]["detractors"] = randomAmount + 1
      expected[DateTime.now.strftime("%b %y")]["average"] = 1/(3*randomAmount+3).to_f * 100
      
      answer = helper.get_nps_response(DateTime.now - 2.days, DateTime.now, "Months")
      
      answer.should eq(expected)
    end
    
    it "should create keys for each month" do
      survey = @survey
      
      expected = Hash.new
      survey.results << FactoryGirl.create(:detractor_one_month_ago)
      survey.results << FactoryGirl.create(:promoter_now)
      
      expected[DateTime.now.strftime("%b %y")] = Hash.new
      expected[DateTime.now.strftime("%b %y")]["promoters"] = 1
      expected[DateTime.now.strftime("%b %y")]["neutrals"] = 0
      expected[DateTime.now.strftime("%b %y")]["detractors"] = 0
      expected[DateTime.now.strftime("%b %y")]["average"] = 100.to_f
      
      expected[(DateTime.now - 1.months).strftime("%b %y")] = Hash.new
      expected[(DateTime.now - 1.months).strftime("%b %y")]["promoters"] = 0
      expected[(DateTime.now - 1.months).strftime("%b %y")]["neutrals"] = 0
      expected[(DateTime.now - 1.months).strftime("%b %y")]["detractors"] = 1
      expected[(DateTime.now - 1.months).strftime("%b %y")]["average"] = -100.to_f
      
      answer = helper.get_nps_response(DateTime.now - 1.months, DateTime.now, "Months")
      answer.should eq(expected)
    end
    
    it "should create hashes according to step" do
      answer = helper.get_nps_response(DateTime.now - 2.days, DateTime.now, "Days")
      wrong = Hash.new
      wrong[DateTime.now.strftime("%b %y")] = Hash.new
      wrong[DateTime.now.strftime("%b %y")]["promoters"] = 0
      wrong[DateTime.now.strftime("%b %y")]["neutrals"] = 0
      wrong[DateTime.now.strftime("%b %y")]["detractors"] = 0
      wrong[DateTime.now.strftime("%b %y")]["average"] = 0
      
      expected = Hash.new
      expected[(DateTime.now).strftime("%e/%m")] = Hash.new
      expected[(DateTime.now).strftime("%e/%m")]["promoters"] = 0
      expected[(DateTime.now).strftime("%e/%m")]["neutrals"] = 0
      expected[(DateTime.now).strftime("%e/%m")]["detractors"] = 0
      expected[(DateTime.now).strftime("%e/%m")]["average"] = 0
      
      expected[(DateTime.now - 1.days).strftime("%e/%m")] = Hash.new
      expected[(DateTime.now - 1.days).strftime("%e/%m")]["promoters"] = 0
      expected[(DateTime.now - 1.days).strftime("%e/%m")]["neutrals"] = 0
      expected[(DateTime.now - 1.days).strftime("%e/%m")]["detractors"] = 0
      expected[(DateTime.now - 1.days).strftime("%e/%m")]["average"] = 0
      
      expected[(DateTime.now - 2.days).strftime("%e/%m")] = Hash.new
      expected[(DateTime.now - 2.days).strftime("%e/%m")]["promoters"] = 0
      expected[(DateTime.now - 2.days).strftime("%e/%m")]["neutrals"] = 0
      expected[(DateTime.now - 2.days).strftime("%e/%m")]["detractors"] = 0
      expected[(DateTime.now - 2.days).strftime("%e/%m")]["average"] = 0
      answer.should_not eq(wrong)
    end
  end
end

