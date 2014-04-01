require 'android_resource_file'
require "spec_helper"

describe 'Android resource file parser' do
  let(:file_path) { File.expand_path("../../fixtures/#{file_name}.xml", __FILE__) }
  let(:parsed) { AndroidResourceFile.parse(File.new(file_path)) }

  shared_examples "Resource file parsing" do
    it "should return keys in UTF-8" do
      parsed.keys.first.encoding.should == Encoding::UTF_8
    end

    it "can give a count of the keys" do
      parsed.keys.count.should == 3
    end

    it "can give a list of the keys" do
      parsed.keys.should == ["Adding", "Almost done", "Done"]
    end

    it "can give a list of values" do
      parsed.values.should == ["Adding...", "Almost done...", "Done!"]
    end

    it "should return values in UTF-8 encoding" do
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

  context "simple file (no plurals or fancypants)" do
    let(:file_name) { "simple_strings" }
    include_examples "Resource file parsing"
  end
  # describe "with leading comment" do
  #   let(:string_file_name) { "parsed" }
  #   include_examples "Resource file parsing"
  # end
end