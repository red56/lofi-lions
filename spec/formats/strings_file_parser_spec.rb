# frozen_string_literal: true

require "spec_helper"

describe "Strings file parser" do
  let(:file_path) { File.expand_path("../../fixtures/#{file_name}.strings", __FILE__) }
  let(:parsed) { IOS::StringsFile.parse(File.new(file_path)) }

  shared_examples "String file parsing" do
    it "returns keys in UTF-8" do
      expect(parsed.keys.first.encoding).to eq(Encoding::UTF_8)
    end

    it "can give a count of the keys" do
      expect(parsed.keys.count).to eq(3)
    end

    it "can give a list of the keys" do
      expect(parsed.keys).to eq(["Adding", "Almost done", "Done"])
    end

    it "returns keys in UTF-8 encoding" do
      expect(parsed.keys.first.encoding).to eq(Encoding::UTF_8)
    end

    it "can return a hash form" do
      expected = [["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]]
      hash = parsed.to_hash
      hash.keys.each_with_index do |key, i|
        l = hash[key]
        expect(l).to be_instance_of Localization
        expect(key).to eq(expected[i].first)
        expect(l.key).to eq(expected[i].first)
        expect(l.value).to eq(expected[i].last)
      end
    end

    it "allows for iteration over the key, value pairs" do
      result = []
      parsed.each do |string|
        expect(string).to be_instance_of Localization
        result << [string.key, string.value]
      end
      expect(result).to eq([["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]])
    end
  end

  describe "with leading comment" do
    let(:file_name) { "with_leading_comment" }

    include_examples "String file parsing"
  end

  describe "with inline comment" do
    let(:file_name) { "with_inline_comment" }

    include_examples "String file parsing"
  end

  describe "with trailing comment" do
    let(:file_name) { "with_trailing_comment" }

    include_examples "String file parsing"
  end

  describe "with no comment" do
    let(:file_name) { "with_no_comment" }

    include_examples "String file parsing"
  end

  describe "with escaped characters" do
    let(:file_name) { "with_escaped_characters" }

    it "can give a count of the keys" do
      expect(parsed.keys.count).to eq(1)
    end

    it "can give a list of the keys" do
      expect(parsed.keys).to eq(["Almost done"])
    end

    it "can give values" do
      expect(parsed.localizations.first.value).to eq("Almost \"done\"\nanother line")
    end
  end

  describe "with missing localisations" do
    let(:file_name) { "with_missing_values" }

    it "can parse the file" do
      expect(parsed.keys).to eq(["Adding", "Almost done", "Done"])
      expect(parsed.values).to eq(["Adding...", "", ""])
    end
  end
end
