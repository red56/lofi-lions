require 'rails_helper'

RSpec.describe ProjectLanguage, :type => :model do
  let(:project) { create :project }
  let(:language) { create :language }

  describe "recalculate_counts!" do
    let(:project_language) { create :project_language, project: project, language: language }
    let(:master_texts) { create_list :master_text, 2, project: project }

    context "with none complete" do
      let!(:localized_texts) { master_texts.map { |mt|
        create(:localized_text, master_text: mt, project_language: project_language,text: '')
      } }
      it 'can recalculate' do
        expect { project_language.recalculate_counts! }.to change {
              [project_language.need_review_count, project_language.need_entry_count]
            }.to [0, 2]
      end
    end
    context "with one needing review" do
      let!(:localized_texts) { [
          create(:localized_text, master_text: master_texts.first, project_language: project_language, text: 'some',
              needs_review:
                  true),
          create(:localized_text, master_text: master_texts.last, project_language: project_language, text: '')
      ] }
      it 'can recalculate' do
        expect { project_language.recalculate_counts! }.to change {
              [project_language.need_review_count, project_language.need_entry_count]
            }.to [1, 1]
      end
    end
    context "with all done" do
      let!(:localized_texts) { [
          create(:localized_text, master_text: master_texts.first, project_language: project_language, text: 'some'),
          create(:localized_text, master_text: master_texts.last, project_language: project_language, text: 'done')
      ] }
      it 'can recalculate' do
        expect { project_language.recalculate_counts! }.to change {
              [project_language.need_review_count, project_language.need_entry_count]
            }.to [0, 0]
      end
    end

  end

  describe "#next_localized_text" do
    let!(:project_language) {create(:project_language)}

    context "with no arguments" do
      subject { project_language.next_localized_text() }

      context "with one existing localized text to enter" do
        let!(:localized_text){ create(:localized_text, project_language: project_language, needs_entry: true )}
        it{ is_expected.to eq(localized_text)}
      end
      context "with one existing localized text to review" do
        let!(:localized_text){ create(:localized_text, project_language: project_language, needs_review: true )}
        it{ is_expected.to eq(localized_text)}
      end
      context "with no existing localized text to do" do
        it{ is_expected.to be_nil }
      end
    end

  end
end
