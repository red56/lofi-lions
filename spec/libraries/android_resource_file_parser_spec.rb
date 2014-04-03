require "spec_helper"

describe 'Android resource file parser' do
  let(:file_path) { File.expand_path("../../fixtures/#{file_name}.xml", __FILE__) }
  let(:parsed) { Android::ResourceFile.parse(File.new(file_path)) }

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

  context "file with plurals" do
    let(:file_name) { "strings_with_plurals" }
    it "should return keys in UTF-8" do
      parsed.keys.first.encoding.should == Encoding::UTF_8
    end

    it "can give a count of the keys" do
      parsed.keys.count.should == 3
    end

    it "can give a list of the keys" do
      parsed.keys.should == ["login_to_get_started", "email", "remaining_days"]
    end

    it "can give a list of plural values" do
      parsed.to_hash['remaining_days'].should == Localization.new('remaining_days', one: '%d day', other: '%d days')
    end
  end

  context "file with string arrays" do
    let(:file_name) { "strings_with_array" }
    it "should return keys in UTF-8" do
      parsed.keys.first.encoding.should == Encoding::UTF_8
    end

    it "can give a list of the keys" do
      parsed.keys.should == ["login_to_get_started", "email", "server_choice[0]", 'server_choice[1]']
    end

    it "can give a the array items" do
      parsed.to_hash['server_choice[0]'].should == Localization.new('server_choice[0]', 'Production')
      parsed.to_hash['server_choice[1]'].should == Localization.new('server_choice[1]', 'Staging')
    end
  end

  context "file with escaped characters" do
    let(:file_name) { "with_escaped_characters" }
    it "unescapes apostrophes" do
      local = parsed.localizations.detect { |l| l.key == "apostrophe"}
      local.value.should == "don't"
    end
    it "unescapes double quotes" do
      local = parsed.localizations.detect { |l| l.key == "double"}
      local.value.should == '"double"'
    end
    it "unescapes mixed escapes" do
      local = parsed.localizations.detect { |l| l.key == "both"}
      local.value.should == '"don\'t"'
    end
  end

  context "real world example" do
    let(:file_name) { "full_example" }
    it "works" do
      parsed
    end
  end

end