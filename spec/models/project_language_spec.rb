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
    let!(:project_language) { create(:project_language) }

    let(:mt_able) { create(:master_text, project: project, key: "able") }
    let(:mt_baker) { create(:master_text, project: project, key: "baker") }
    let(:mt_charlie) { create(:master_text, project: project, key: "charlie") }
    context "with several needing entry" do
      let(:able) { create(:localized_text, project_language: project_language, master_text: mt_able, needs_entry: true, needs_review: false) }
      let(:baker) { create(:localized_text, project_language: project_language, master_text: mt_baker, needs_entry: true, needs_review: false) }
      let(:charlie) { create(:localized_text, project_language: project_language, master_text: mt_charlie, needs_entry: true, needs_review: false) }

      before { baker; charlie; able }
      it "if i give it no id it returns able's" do
        expect(project_language.next_localized_text()).to eq(able)
      end
      it "if i give it a nil it returns able's" do
        expect(project_language.next_localized_text(nil)).to eq(able)
        expect(project_language.next_localized_text('')).to eq(able)
      end
      it "if i give it able's key it returns baker" do
        expect(project_language.next_localized_text(able.key)).to eq(baker)
      end

      it "if i give it baker's key it returns charlie" do
        expect(project_language.next_localized_text(baker.key)).to eq(charlie)
      end

      it "if i give a non-existant key before baker it returns baker" do
        expect(project_language.next_localized_text('baa')).to eq(baker)
      end

      it "if i give it charlies's key it returns able" do
        expect(project_language.next_localized_text(charlie.key)).to eq(able)
      end


      context "if baker just requires review" do
        let(:baker) { create(:localized_text, project_language: project_language, master_text: mt_baker,
            text: 'something', needs_entry: false, needs_review: true) }
        it "if i give it able's key it returns baker" do
          expect(project_language.next_localized_text(able.key)).to eq(baker)
        end

      end
      context "if baker is all translated" do
        let(:baker) { create(:localized_text, project_language: project_language, master_text: mt_baker,
            text: 'something', needs_entry: false, needs_review: false) }
        it "if i give it able's key it returns charlie" do
          expect(project_language.next_localized_text(able.key)).to eq(charlie)
        end
      end
    end

    context "with no localized texts" do
      it "given no key returns nil" do
        expect(project_language.next_localized_text()).to be_nil
      end
      it "given key returns nil" do
        expect(project_language.next_localized_text('some-key')).to be_nil
      end
    end
    context "with only one key needing review or entry" do
      let!(:baker) { create(:localized_text, project_language: project_language, master_text: mt_baker, needs_entry:
              true, needs_review: false) }

      it "given no key returns the localized text" do
        expect(project_language.next_localized_text()).to eq baker
      end
      it "given key returns the localized text" do
        expect(project_language.next_localized_text(baker.key)).to eq baker
      end
    end
    # end
  end

  describe "google_translate_missing" do
    let(:mt1) {create(:master_text, key: 'mt1', other: "some mt1 words")}
    let(:mt2) {create(:master_text, key: 'mt2', other: "some mt2 text")}
    let(:mt3) {create(:master_text, key: 'mt3', other: "some mt3 sentences")}
    let(:project_language) {create(:project_language, language: create(:language, code: 'de'))}
    subject { project_language.google_translate_missing }
    context "with one" do
      let!(:missing_entry) {create(:localized_text, master_text: mt1, other: "", project_language: project_language)}
      it "will send off one to google" do
        expect(project_language).to receive(:recalculate_counts!).and_call_original
        expect_any_instance_of(LocalizedText).to receive(:google_translated!).and_call_original
        expect(EasyTranslate).to receive(:translate)
          .with(["some mt1 words"], from: 'en', to: 'de', format: 'text')
          .and_return(["einige mt1 Wörter"])
        expect {
          subject
        }.to change{missing_entry.reload.other}.from("").to("einige mt1 Wörter")
        expect(subject).to eq(1)
      end
    end

    context "with none" do
      let!(:has_entry) {create(:localized_text, master_text: mt1, other: "whoah", project_language: project_language)}
      it "won't" do
        expect(EasyTranslate).not_to receive(:translate)
        expect(project_language).not_to receive(:recalculate_counts!)
        expect(subject).to eq(0)
      end
    end
    context "with multiple" do
      let!(:missing_entry1) {create(:localized_text, master_text: mt1, other: "", project_language: project_language)}
      let!(:has_entry) {create(:localized_text, master_text: mt2, other: "whoah", project_language: project_language)}
      let!(:missing_entry3) {create(:localized_text, master_text: mt3, other: "", project_language: project_language)}
      it "will send off one to google" do
        expect(EasyTranslate).to receive(:translate)
          .with(["some mt1 words", "some mt3 sentences"], from: 'en', to: 'de', format: 'text')
          .and_return(["einige mt1 Wörter", "einige mt3 Sätze"])
        expect {
          subject
        }.to change{missing_entry3.reload.other}.from("").to("einige mt3 Sätze")
        expect(subject).to eq(2)
      end
    end
  end
end
