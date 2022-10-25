# frozen_string_literal: true

require "rails_helper"

RSpec.describe CronMailer, type: :mailer do
  describe "translation_status_report" do
    let(:mail) { described_class.translation_status_report }

    before do
      travel_to(DateTime.parse("2022-10-01 03:00"))
    end

    context "with an admin" do
      let!(:admin) { create(:user, is_administrator: true) }

      it "renders the headers" do
        expect(mail.subject).to eq("Translation status October 01, 2022")
        expect(mail.to).to eq([admin.email])
        expect(mail.from).to eq(["cron@example.com"])
      end
    end

    context "with a language" do
      let!(:project_language) { create(:project_language) }
      let!(:master_text) { create(:master_text, project: project_language.project) }
      let!(:localized_text) { create(:localized_text, project_language: project_language, needs_entry: true, needs_review: true) }

      it "renders the body" do
        expect(mail.body.encoded).to match(project_language.language_name)
        expect(mail.body.encoded).to match(/1/) # needs_entry
        expect(mail.body.encoded).to match(/0/) # needs_review
      end
    end
  end
end
