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
end
