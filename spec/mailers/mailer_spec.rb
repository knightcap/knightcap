require "spec_helper"

describe Mailer do
  describe "invitation" do
    let(:mail) { Mailer.invitation("test@yopmail.com", FactoryGirl.create(:service_with_results), "link")}

    it "renders the headers" do
      mail.subject.should eq("Suncorp Survey")
      mail.to.should eq(["test@yopmail.com"])
      mail.from.should eq(["from@example.com"])
    end

  end

end
