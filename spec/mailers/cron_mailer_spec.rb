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

  describe "translator_update" do
    let!(:translator){create(:user, project_languages: [project_language])}
    let!(:project_language){create(:project_language)}
    let!(:other_project_language){create(:project_language)}

    it "should work" do
      expect {
        CronMailer.translator_update(translator).deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(email_doc).to have_link_to(project_language_url(project_language))
      expect(email_doc).to_not have_link_to(project_language_url(other_project_language))
    end
  end
end
