require 'rails_helper'

describe CronMailer, type: :mailer do

  let(:email_doc) { Nokogiri.HTML(ActionMailer::Base.deliveries.first.body.raw_source)
  }
  describe "translation_status_report" do
    let(:admin) { 'tim@example.com' }

    it "should work" do
      expect {
        CronMailer.translation_status_report([admin]).deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(email_doc).to have_link_to("http://www.example.com/project_languages")
    end
  end

end
