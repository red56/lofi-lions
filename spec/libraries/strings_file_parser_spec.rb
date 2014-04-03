require 'ios'
require "spec_helper"

describe 'Strings file parser' do
  let(:file_path) { File.expand_path("../../fixtures/#{file_name}.strings", __FILE__) }
  let(:parsed) { IOS::StringsFile.parse(File.new(file_path)) }

  shared_examples "String file parsing" do
    it "should return keys in UTF-8" do
      parsed.keys.first.encoding.should == Encoding::UTF_8
    end

    it "can give a count of the keys" do
      parsed.keys.count.should == 3
    end

    it "can give a list of the keys" do
      parsed.keys.should == ["Adding", "Almost done", "Done"]
    end

    it "should return keys in UTF-8 encoding" do
      parsed.keys.first.encoding.should == Encoding::UTF_8
    end

    it "can return a hash form" do
      expected = [["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]]
      hash = parsed.to_hash
      hash.keys.each_with_index do |key, i|
        l = hash[key]
        l.should be_instance_of Localization
        key.should == expected[i].first
        l.key.should == expected[i].first
        l.value.should == expected[i].last
      end
    end

    it "allows for iteration over the key, value pairs" do
      result = []
      parsed.each do |string|
        string.should be_instance_of Localization
        result << [string.key, string.value]
      end
      result.should == [["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]]
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
      parsed.keys.count.should == 1
    end

    it "can give a list of the keys" do
      parsed.keys.should == ["Almost done"]
    end

    it "can give values" do
      parsed.localizations.first.value.should == "Almost \"done\"\nanother line"
    end
  end
end