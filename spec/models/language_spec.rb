# frozen_string_literal: true

require "rails_helper"

describe Language, type: :model do
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
      language.name = ""
      expect(language).not_to be_valid
    end

    it "requires code" do
      language.code = nil
      expect(language).not_to be_valid
    end

    it "requires code" do
      language.code = ""
      expect(language).not_to be_valid
    end
  end

  describe "plurals" do
    let(:language) { build(:language) }

    it "should be a hash" do
      expect(language.plural_forms_with_fields).to be_a(Hash)
    end

    context "with some specific labels type_0_chinese" do
      let(:language) { build(:language, :type_0_chinese) }

      it "should be the specified hash" do
        expect(language.plural_forms_with_fields).to eq({ other: "everything" })
      end
    end

    context "with some specific labels type_1_english" do
      let(:language) { build(:language, :type_1_english) }

      it "should be the specified hash" do
        expect(language.plural_forms_with_fields).to eq({ one: "is 1", other: "everything else" })
      end
    end
  end

  describe "code for google" do
    it "is mostly the same" do
      expect(build(:language, code: "de").code_for_google).to eq("de")
      expect(build(:language, code: "fr").code_for_google).to eq("fr")
      expect(build(:language, code: "pt-BR").code_for_google).to eq("pt-BR")
    end

    it "it is normalized for chinese" do
      expect(build(:language, code: "zh").code_for_google).to eq("zh-CN")
    end
  end
end
