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

    describe "singular" do
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
    end

    describe "plurals" do
      let(:plural_master_texts) { %w(fish sheep) }

      before do
        @plural_master_texts = plural_master_texts.map do |key|
          MasterText.create(key: key, one: key, other: "#{key}s", pluralizable: true)
        end
        @master_texts.concat(@plural_master_texts)
        @fr = Language.create(code: "fr", name: "French", pluralizable_label_zero: "zero", pluralizable_label_one: "one", pluralizable_label_many: "many")
        @master_texts.each do |mt|
          case mt.pluralizable?
          when true
            LocalizedText.create({
              master_text: mt,
              language: @fr,
              one: [mt.key, @fr.code, "one"].join(":"),
              zero: [mt.key, @fr.code, "zero"].join(":"),
              many: [mt.key, @fr.code, "many"].join(":")
            })
          when false
            LocalizedText.create(master_text: mt, language: @fr, other: [mt.key, @fr.code].join(":"))
          end
        end
      end

      it "includes the plural forms in the xml" do
        get platform, language: @fr.code
        resource = Android::ResourceFile.parse(response.body)
        locals = resource.localizations
        plurals = locals.select { |l| plural_master_texts.include?(l.key) }
        plurals.length.should == plural_master_texts.length
        plurals.each do |plur|
          [:one, :zero, :many].each do |amount|
            plur.value[amount].should == [plur.key, @fr.code, amount].join(":")
          end
        end
      end
    end

    describe "arrays" do
      let(:array_master_texts) { %w(planet[0] planet[1] planet[2] door[0] door[1]) }
      before do
        @array_master_texts = array_master_texts.map do |key|
          MasterText.create(key: key, other: "#{key}", pluralizable: false)
        end
        @array_master_texts.each_with_index do |mt, n|
          LocalizedText.create({
            master_text: mt,
            language: language,
            other: [mt.key, language.code, "#{n}"].join(":")
          })
        end
      end

      it "includes array forms in the xml" do
        get platform, language: language.code
        doc = Nokogiri::XML(response.body)
        array = doc.css('string-array[name="planet"]')
        array.length.should == 1
        array = array.first
        items = array.css("item")
        items.length.should == 3
        items.map(&:text).should == ["planet[0]:ja:0", "planet[1]:ja:1", "planet[2]:ja:2"]

        array = doc.css('string-array[name="door"]')
        array.length.should == 1
        array = array.first
        items = array.css("item")
        items.length.should == 2
        items.map(&:text).should == ["door[0]:ja:3", "door[1]:ja:4"]
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
