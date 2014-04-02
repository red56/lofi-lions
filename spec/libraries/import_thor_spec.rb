require "spec_helper"
require 'thor'
load File.join(Rails.root.join('lib/tasks/import.thor'))

describe 'ImportThor' do
  let(:chinese) { build_stubbed(:language, :type_0_chinese, code: 'zh', name: "Chinese") }

  describe "Ios" do
    it "is instantiated ok" do
      ImportThor::Ios.new
    end

    it "can run something against a file" do
      Language.should_receive(:find_by_code).with('zh').and_return(chinese)
      Localization.should_receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection)).and_return({})
      ImportThor::Ios.new.localizations('zh', Rails.root.join('spec/fixtures/with_escaped_characters.strings'))
    end

    it "should stop if it receives unknown code" do
      Language.should_receive(:find_by_code).with('zh').and_return(nil)
      Localization.should_not_receive(:create_localized_texts)
      ImportThor::Ios.new.localizations('zh', Rails.root.join('spec/fixtures/with_escaped_characters.strings'))
    end
  end
  describe "Android" do
    it "is instantiated ok" do
      ImportThor::Android.new
    end

    it "can run something against a file" do
      Language.should_receive(:find_by_code).with('zh').and_return(chinese)
      Localization.should_receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection)).and_return({})
      ImportThor::Ios.new.localizations('zh', Rails.root.join('spec/fixtures/simple_strings.xml'))
    end

    it "should stop if it receives unknown code" do
      Language.should_receive(:find_by_code).with('zh').and_return(nil)
      Localization.should_not_receive(:create_localized_texts)
      ImportThor::Ios.new.localizations('zh', Rails.root.join('spec/fixtures/simple_strings.xml'))
    end
  end
end