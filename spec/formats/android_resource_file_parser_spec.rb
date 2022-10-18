# frozen_string_literal: true

require "spec_helper"

describe "Android resource file parser" do
  let(:file_path) { File.expand_path("../../fixtures/#{file_name}.xml", __FILE__) }
  let(:parsed) { Android::ResourceFile.parse(File.new(file_path)) }

  shared_examples "Resource file parsing" do
    it "returns keys in UTF-8" do
      expect(parsed.keys.first.encoding).to eq(Encoding::UTF_8)
    end

    it "can give a count of the keys" do
      expect(parsed.keys.count).to eq(3)
    end

    it "can give a list of the keys" do
      expect(parsed.keys).to eq(["Adding", "Almost done", "Done"])
    end

    it "returns values in UTF-8 encoding" do
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

  context "with a simple file (no plurals or fancypants)" do
    let(:file_name) { "simple_strings" }

    include_examples "Resource file parsing"
  end

  context "with a file with plurals" do
    let(:file_name) { "strings_with_plurals" }

    it "returns keys in UTF-8" do
      expect(parsed.keys.first.encoding).to eq(Encoding::UTF_8)
    end

    it "can give a count of the keys" do
      expect(parsed.keys.count).to eq(3)
    end

    it "can give a list of the keys" do
      expect(parsed.keys).to eq(["login_to_get_started", "email", "remaining_days"])
    end

    it "can give a list of plural values" do
      expect(parsed.to_hash["remaining_days"]).to eq(Localization.new("remaining_days", one: "%d day", other: "%d days"))
    end
  end

  context "with a file with string arrays" do
    let(:file_name) { "strings_with_array" }

    it "returns keys in UTF-8" do
      expect(parsed.keys.first.encoding).to eq(Encoding::UTF_8)
    end

    it "can give a list of the keys" do
      expect(parsed.keys).to eq(["login_to_get_started", "email", "server_choice[0]", "server_choice[1]"])
    end

    it "can give a the array items" do
      expect(parsed.to_hash["server_choice[0]"]).to eq(Localization.new("server_choice[0]", "Production"))
      expect(parsed.to_hash["server_choice[1]"]).to eq(Localization.new("server_choice[1]", "Staging"))
    end
  end

  context "with a file with escaped characters" do
    let(:file_name) { "with_escaped_characters" }

    it "unescapes apostrophes" do
      local = parsed.localizations.detect { |l| l.key == "apostrophe" }
      expect(local.value).to eq("don't")
    end

    it "unescapes double quotes" do
      local = parsed.localizations.detect { |l| l.key == "double" }
      expect(local.value).to eq('"double"')
    end

    it "unescapes mixed escapes" do
      local = parsed.localizations.detect { |l| l.key == "both" }
      expect(local.value).to eq('"don\'t"')
    end
  end

  context "with a real world example" do
    let(:file_name) { "full_example" }

    it "works" do
      parsed
    end
  end
end
