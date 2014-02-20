require 'strings_file'
require "spec_helper"

describe 'Strings file parser' do
  let(:strings_file_path) { File.expand_path("../../fixtures/#{string_file_name}.strings", __FILE__) }
  let(:strings_file) { File.new(strings_file_path) }

  let(:strings) { StringsFile.parse(strings_file) }

  shared_examples "String file parsing" do
    it "should return keys in UTF-8" do
      strings.keys.first.encoding.should == Encoding::UTF_8
    end

    it "can give a count of the keys" do
      strings.keys.count.should == 3
    end

    it "can give a list of the keys" do
      strings.keys.should == ["Adding", "Almost done", "Done"]
    end

    it "can give a list of values" do
      strings.values.should == ["Adding...", "Almost done...", "Done!"]
    end

    it "should return values in UTF-8 encoding" do
      strings.keys.first.encoding.should == Encoding::UTF_8
    end

    it "can return a hash form" do
      expected = [["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]]
      hash = strings.to_hash
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
      strings.each do |string|
        string.should be_instance_of Localization
        result << [string.key, string.value]
      end
      result.should == [["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]]
    end
  end

  describe "with leading comment" do
    let(:string_file_name) { "with_leading_comment" }
    include_examples "String file parsing"
  end

  describe "with inline comment" do
    let(:string_file_name) { "with_inline_comment" }
    include_examples "String file parsing"
  end

  describe "with trailing comment" do
    let(:string_file_name) { "with_trailing_comment" }
    include_examples "String file parsing"
  end

  describe "with no comment" do
    let(:string_file_name) { "with_no_comment" }
    include_examples "String file parsing"
  end

  describe "with escaped characters" do
    let(:string_file_name) { "with_escaped_characters" }

    it "can give a count of the keys" do
      strings.keys.count.should == 1
    end

    it "can give a list of the keys" do
      strings.keys.should == ["Almost done"]
    end

    it "can give a list of values" do
      strings.values.should == ['Almost \"done\"\nanother line']
    end
  end
end