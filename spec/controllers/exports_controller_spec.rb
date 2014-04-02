require 'spec_helper'

describe ExportsController do
  let(:languages) { [:en, :ja] }
  let(:master_texts) { %w(title welcome complete) }
  let(:language) { Language.where(code: 'ja').first }
  let(:master_text) { MasterText.where(key: 'title').first }

  before do
    @master_texts = master_texts.map do |key|
      MasterText.create(key: key, other: key)
    end
    @languages = languages.map do |code|
      Language.create(name: code, code: code)
    end
    @languages.each do |lang|
      @master_texts.each do |mt|
        LocalizedText.create(master_text: mt, language: lang, other: [mt.key, lang.code].join(":"))
      end
    end
  end

  describe "ios" do
    let(:platform) { :ios }
    before do
      get platform, language: language.code
    end

    it "should return a zip file" do
      response.content_type.should == "application/octet-stream"
    end

    it "has a relative filename in the headers" do
      response.header["X-Path"].should == "ja.lproj/Localizable.strings"
    end

    describe "escaping" do
      before do
        lt = LocalizedText.where(language: language, master_text: master_text).first
        lt.update_attributes(other: text)
        get platform, language: language.code
        resource = IOS::StringsFile.parse(StringIO.new(response.body))
        @string = resource.localizations.detect { |l| l.key == master_text.key }.text
      end

      context "double quotes" do
        let(:text) { "\"that's\" crazy" }

        it "are escaped correctly" do
          @string.should == "\\\"that's\\\" crazy"
        end
      end
    end
  end

  describe "android" do
    let(:platform) { :android }

    before do
      get platform, language: language.code
    end

    it "should return a zip file" do
      response.content_type.should == "text/xml"
    end

    it "has a relative filename in the headers" do
      response.header["X-Path"].should == "res/values-ja/strings.xml"
    end

    it "returns a valid xml document for a language" do
      # io = StringIO.new(response.body)
      resource = Android::ResourceFile.parse(response.body)
      locals = resource.localizations
      locals.map(&:key).sort.should == master_texts.sort
      master_texts.each do |key|
        string = locals.detect { |l| l.key == key }
        string.text.should == "#{key}:ja"
      end
    end

    describe "escaping" do
      before do
        lt = LocalizedText.where(language: language, master_text: master_text).first
        lt.update_attributes(other: text)
        get platform, language: language.code
        resource = Android::ResourceFile.parse(response.body)
        @string = resource.localizations.detect { |l| l.key == master_text.key }.text#@doc.css("string[name='#{master_text.key}']").first.text
      end

      context "apostrophes" do
        let(:text) { "that's crazy" }

        it "are escaped correctly" do
          @string.should == "that\\'s crazy"
        end
      end

      context "double quotes" do
        let(:text) { "\"that's\" crazy" }

        it "are escaped correctly" do
          @string.should == "\\\"that\\'s\\\" crazy"
        end
      end
    end
  end
end
