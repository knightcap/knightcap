require 'spec_helper'

describe WidgetsHelper do
  
  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    current_user = user
    
    @service = FactoryGirl.create(:service_with_results)
    team = @service.team
    team.users << current_user
  end
  
  describe "Responses widget: " do
    it "should give me Responses widget" do
      responseWidget = Widget.responses
      helper.displayWidget( responseWidget ).should eq("0/0")
    end
    
    it "should count all completed responses" do
      @service.surveys.first.results << FactoryGirl.create(:detractor_now)
      responseWidget = Widget.responses
      helper.displayWidget( responseWidget ).should eq("1/1")
    end
    
    it "should not count non-completed responses" do
      @service.surveys.first.results << FactoryGirl.create(:detractor_now)
      @service.surveys.first.results << FactoryGirl.create(:new_result)
      responseWidget = Widget.responses
      helper.displayWidget( responseWidget ).should eq("1/2")
    end
    
    it "should count responses by month" do
       @service.surveys.first.results << FactoryGirl.create(:detractor_one_month_ago)
       @service.surveys.first.results << FactoryGirl.create(:detractor_now)
       responseWidget = Widget.responses #default step is monthly
       helper.displayWidget( responseWidget ).should eq("1/1")
    end
    
    it "should count responses by year if step is changed" do
       @service.surveys.first.results << FactoryGirl.create(:detractor_one_month_ago)
       @service.surveys.first.results << FactoryGirl.create(:detractor_now)
       responseWidget = Widget.responses #default step is monthly
       responseWidget.step = "Yearly"
       helper.displayWidget( responseWidget ).should eq("2/2")
    end
  end
  
  describe "pdn widgets: " do
    it "should return promoters/neutrals/detractors accordingly" do
      # 0 neutral, 1 detractor, 2 promoter
       @service.surveys.first.results << FactoryGirl.create(:detractor_now)
       @service.surveys.first.results << FactoryGirl.create(:promoter_now)
       @service.surveys.first.results << FactoryGirl.create(:promoter_now)
       
       promoterWidget = Widget.promoters
       helper.displayWidget( promoterWidget ).should eq(2)
       
       detractorWidget = Widget.detractors
       helper.displayWidget( detractorWidget ).should eq(1)
    
       neutralWidget = Widget.neutrals
       helper.displayWidget( neutralWidget ).should eq(0)
    end
    
    it "should only return values from this month" do
       @service.surveys.first.results << FactoryGirl.create(:promoter_now)
       @service.surveys.first.results << FactoryGirl.create(:promoter_one_month_ago)
       
       promoterWidget = Widget.promoters
       helper.displayWidget( promoterWidget ).should eq(1)
    end
    
    it "should only return values from this year if step is changed" do
       @service.surveys.first.results << FactoryGirl.create(:promoter_now)
       @service.surveys.first.results << FactoryGirl.create(:promoter_one_month_ago)
       
       promoterWidget = Widget.promoters
       promoterWidget.step = "Yearly"
       helper.displayWidget( promoterWidget ).should eq(2)
    end
  end
end
