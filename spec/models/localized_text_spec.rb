require 'spec_helper'

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
    it "requires language id" do
      localized_text.language_id = nil
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

end