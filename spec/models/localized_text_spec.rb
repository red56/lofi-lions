require 'rails_helper'

describe LocalizedText, :type => :model do
  let(:localized_text) { build(:localized_text, text: 'something').tap do |localized_text|
    allow(localized_text).to receive_messages(pluralizable: pluralizable, language: language)
  end
  }
  let(:language) { build(:language) }
  let(:pluralizable) { false }

  describe "validations" do
    it "basically works" do
      expect(localized_text).to be_valid
    end
    it "requires master_text_id" do
      localized_text.master_text_id = nil
      expect(localized_text).not_to be_valid
    end
    it "requires project language" do
      localized_text.project_language_id = nil
      expect(localized_text).not_to be_valid
    end
  end

  context "unpluralizable" do
    let(:pluralizable) { false }
    it "can get text" do
      expect(localized_text.text).to eq('something')
    end
    it "can set text" do
      localized_text.text = 'something'
    end
  end

  context "pluralizable" do
    let(:pluralizable) { true }
    it "can't get text" do
      expect {
        localized_text.text
      }.to raise_error
    end
    it "can set text" do
      localized_text.text = 'something'
    end
  end

  describe "#markdown?" do
    let(:localized_text) { build(:localized_text, text: 'something', master_text: master_text) }
    let(:master_text) { build(:master_text, format: format) }
    subject{localized_text}
    context "markdown" do
      let(:format) { MasterText::MARKDOWN_FORMAT }
      it { is_expected.to be_markdown }
    end
    context "plain" do
      let(:format) { MasterText::PLAIN_FORMAT }
      it { is_expected.not_to be_markdown }
    end
  end


  describe "calculate needs_entry" do
    it "is called and set on validate" do
      expect(localized_text).to receive(:calculate_needs_entry).and_return('true')
      expect {
        localized_text.valid?
      }.to change { localized_text.needs_entry }
    end

    context "unpluralizable" do
      it "is true if text is empty" do
        localized_text.text = ''
        expect(localized_text.calculate_needs_entry).to be_truthy
      end
      it 'is false if text is filled' do
        localized_text.text = 'fillll'
        expect(localized_text.calculate_needs_entry).to be_falsey
      end
    end

    context "pluralizable" do
      let(:pluralizable) { true }
      before do
        #fill everything
        localized_text.update_attributes(one: 'one', two: 'two', few: 'few', many: 'many', other: 'other')
      end
      context "with language of Plural rule #0" do
        let(:language) { build :language, :type_0_chinese }
        it "is true if other is empty" do
          localized_text.other = ''
          expect(localized_text.calculate_needs_entry).to be_truthy
        end
        it 'is false if everything important is filled' do
          localized_text.one = ''
          expect(localized_text.calculate_needs_entry).to be_falsey
        end
      end

      context "with language of Plural rule #1" do
        let(:language) { build :language, :type_1_english }
        it "is true if one is empty" do
          localized_text.one = ''
          expect(localized_text.calculate_needs_entry).to be_truthy
        end
        it "is true if other is empty" do
          localized_text.other = ''
          expect(localized_text.calculate_needs_entry).to be_truthy
        end
        it 'is false if everything important is filled' do
          localized_text.few = ''
          expect(localized_text.calculate_needs_entry).to be_falsey
        end
      end
    end
  end

  describe "adding to the translated_from field" do
    let(:localized_text) { create(:to_review_localized_text, master_text: master_text).tap do |localized_text|
      localized_text.translated_from = nil
    end
    }
    let(:master_text) { create(:master_text, text: "some text") }

    it "saves once localized text reviewed" do
      expect {
        localized_text.update_attributes!(needs_review: false)
      }.to change { localized_text.translated_from }.to(master_text.text)
    end

    it "adds time to translated at" do
      expect {
        localized_text.update_attributes!(needs_review: false)
      }.to change { localized_text.translated_at }
    end

    it "doesn't save if needs_review is true" do
      expect {
        localized_text.save!
      }.to_not change { localized_text.translated_from }
    end

    it "is not set when first created" do
      create :project_language, project: master_text.project;
      LocalizedTextEnforcer.new.master_text_created(master_text)
      localized_text = master_text.reload.localized_texts.first
      expect(localized_text.translated_from).to eq nil
    end
    context "when pluralizable" do
      let(:master_text) {create(:master_text, pluralizable: true)}
      it "saves once localized text reviewed" do
        expect {
          localized_text.update_attributes!(needs_review: false)
        }.to_not change { localized_text.translated_from }
      end
    end
  end

  describe "#google_translate_url" do
    let(:localized_text) { create(:localized_text, project_language: project_language, master_text: master_text)}
    let(:project_language) { create(:project_language, project: project, language: language)}
    let(:master_text) { create(:master_text, project: project, other: english_text)}
    let(:project) { create(:project)}
    let(:language) { create(:language, code: language_code)}

    subject { localized_text.google_translate_url }
    context "with single word" do
      let(:english_text) {"text"}
      let(:language_code) {"fr"}
      it "makes url" do
        expect(subject).to eq("https://translate.google.com/#en/fr/text")
      end
    end
    context "with two words in other language" do
      let(:english_text) {"Some text"}
      let(:language_code) {"de"}
      it "makes url" do
        expect(subject).to eq("https://translate.google.com/#en/de/Some%20text")
      end
    end
    context "with chinese" do
      let(:english_text) {"Some text"}
      let(:language_code) {"zh"}
      it "adjust code" do
        expect(subject).to eq("https://translate.google.com/#en/zh-CN/Some%20text")
      end
    end
  end

  describe "#google_translated!" do
    let(:localized_text) {create(:localized_text)}
    subject {localized_text.google_translated!("new stuff")}
    it "updates value" do
      expect {subject}.to change {localized_text.other}.to "new stuff"
    end
    it "sets needs review" do
      expect {subject}.to change {localized_text.needs_review?}.to true
    end
    it "adds comment" do
      expect {subject}.to change {localized_text.comment}.to include("Machine translated with Google ")
    end

    context "if already comment" do
      let(:localized_text) {create(:localized_text, comment: "Important point...")}
      it "adds comment" do
        expect {subject}.to change {localized_text.comment}.to include("Machine translated with Google ")
        expect(localized_text.comment).to start_with("Important point...\n")
      end
    end
  end
end
