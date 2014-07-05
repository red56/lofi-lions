require 'spec_helper'

describe Language, :type => :model do
  describe "validations" do
    let(:language) { build(:language) }
    it "basically works" do
      expect(language).to be_valid
    end
    it "requires name" do
      language.name = nil
      expect(language).not_to be_valid
    end
    it "requires name" do
      language.name = ''
      expect(language).not_to be_valid
    end
    it "requires code" do
      language.code = nil
      expect(language).not_to be_valid
    end
    it "requires code" do
      language.code = ''
      expect(language).not_to be_valid
    end
  end

  describe "plurals" do
    let(:language) { build(:language) }
    it "should be a hash" do
      expect(language.plural_forms_with_fields).to be_a(Hash)
    end
    context "with some specific labels" do
      let(:language) { build(:language, :type_0_chinese) }
      it "should be a hash" do
        expect(language.plural_forms_with_fields).to eq({other: 'everything'})
      end
    end
    context "with some specific labels" do
      let(:language) { build(:language, :type_1_english) }
      it "should be a hash" do
        expect(language.plural_forms_with_fields).to eq({one: 'is 1', other: 'everything else'})
      end
    end
  end
end
