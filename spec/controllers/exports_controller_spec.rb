# encoding: utf-8

require 'rails_helper'

describe ExportsController, :type => :controller do
  let!(:languages) { [:es, :ja].map { |code| Language.create!(name: code, code: code) } }
  let(:keys) { %w(title welcome complete) }
  let(:language) { Language.where(code: 'ja').first }
  let(:language_code) { language.code }
  let(:master_text) { MasterText.where(key: 'title').first }
  let(:master_texts) { keys.map { |key| MasterText.create!(key: key, other: key.capitalize) } }

  def ensure_localised_texts(languages, master_texts)
    languages.each do |lang|
      master_texts.each do |mt|
        LocalizedText.create!(master_text: mt, language: lang, other: [mt.key, lang.code].join(":"))
      end
    end
  end

  before { ensure_localised_texts(languages, master_texts) }

  describe "common" do
    it "returns a 404 if the language is uknown" do
      get :android, language: "xx"
      expect(response.status).to eq(404)
    end
  end
  describe "ios" do
    let(:platform) { :ios }
    let(:body) { response.body[1..-1].encode(Encoding::UTF_8) }
    before do
      get platform, language: language_code
    end

    describe "translated texts" do

      it "should return a zip file" do
        expect(response.content_type).to eq("application/octet-stream; charset=#{Encoding::UTF_16.name}")
      end

      it "has a relative filename in the headers" do
        expect(response.header["X-Path"]).to eq("ja.lproj/Localizable.strings")
      end

      it "should start with a UTF-16LE BOM" do
        bom = response.body.bytes[0..1]
        expect(bom).to eq("\xFF\xFE".bytes)
      end

      it "should have an encoding of UTF16LE" do
        expect(response.body.encoding).to eq(Encoding::UTF_16LE)
      end

      it "should fallback to the english version" do
        # create mt with no localizations
        mt = MasterText.create!(key: "missing", other: "Missing")
        languages.each do |lang|
          LocalizedText.create!(master_text: mt, language: lang, other: "")
        end
        get platform, language: language_code
        file = IOS::StringsFile.parse(StringIO.new(body))
        local = file.localizations.detect { |l| l.key == mt.key }
        expect(local.value).to eq(mt.other)
      end

      it "should order the keys alphabetically" do
        keys = body.lines.map { |line| line.split(/ *= */).first }
        sorted = keys.dup.sort
        expect(keys).to eq(sorted)
      end

      describe "escaping" do
        before do
          lt = LocalizedText.where(language: language, master_text: master_text).first
          lt.update_attributes(other: text)
          get platform, language: language.code
        end

        context "double quotes" do
          let(:text) { "\"that's\"\ncrazy" }

          it "are escaped correctly" do
            expect(body).to match(/^"title" *= *"\\"that's\\"\\ncrazy";$/)
          end

          # round trip
          it "survive re-import" do
            file = IOS::StringsFile.parse(StringIO.new(body))
            local = file.localizations.detect { |l| l.key == master_text.key }
            expect(local.value).to eq(text)
          end
        end
      end
    end

    describe "english texts" do
      let(:language_code) { 'en' }
      it "uses fallbacks to produce the english version" do
        expect(response.status).to eq(200)
      end

      it "uses the master text values" do
        file = IOS::StringsFile.parse(StringIO.new(response.body))
        master_texts.each do |mt|
          local = file.localizations.detect { |l| l.key == mt.key }
          expect(local.value).to eq(mt.other)
        end
      end
    end
  end

  describe "android" do
    let(:platform) { :android }

    describe "singular" do
      before do
        get platform, language: language_code
      end

      it "should return a zip file" do
        expect(response.content_type).to eq("text/xml")
      end

      it "has a relative filename in the headers" do
        expect(response.header["X-Path"]).to eq("res/values-ja/strings.xml")
      end

      it "returns a valid xml document for a language" do
        # io = StringIO.new(response.body)
        resource = Android::ResourceFile.parse(response.body)
        locals = resource.localizations
        expect(locals.map(&:key).sort).to eq(keys.sort)
        keys.each do |key|
          string = locals.detect { |l| l.key == key }
          expect(string.text).to eq("#{key}:ja")
        end
      end

      it "should fallback to the english version" do
        # create mt with no localizations
        mt = MasterText.create!(key: "missing", other: "Missing")
        languages.each do |lang|
          LocalizedText.create!(master_text: mt, language: lang, other: "")
        end
        get platform, language: language_code
        file = Android::ResourceFile.parse(response.body)
        local = file.localizations.detect { |l| l.key == mt.key }
        expect(local.value).to eq(mt.other)
      end
    end

    describe "plurals" do
      let(:plural_keys) { %w(cow duck) }
      let(:plural_master_texts) { plural_keys.map do |key|
        MasterText.create!(key: key, one: key.capitalize, other: "#{key.capitalize}s", pluralizable: true)
      end
      }

      before do
        master_texts.concat(plural_master_texts)
        @fr = Language.create!(code: "fr", name: "French", pluralizable_label_zero: "zero", pluralizable_label_one: "one", pluralizable_label_many: "many")
        master_texts.each do |mt|
          case mt.pluralizable?
            when true
              LocalizedText.create!({
                      master_text: mt,
                      language: @fr,
                      one: [mt.key, @fr.code, "one"].join(":"),
                      zero: [mt.key, @fr.code, "zero"].join(":"),
                      many: [mt.key, @fr.code, "many"].join(":")
                  })
            when false
              LocalizedText.create!(master_text: mt, language: @fr, other: [mt.key, @fr.code].join(":"))
          end
        end
      end

      it "includes the plural forms in the xml" do
        get platform, language: @fr.code
        resource = Android::ResourceFile.parse(response.body)
        locals = resource.localizations
        plurals = locals.select { |l| plural_keys.include?(l.key) }
        expect(plurals.length).to eq(plural_keys.length)
        plurals.each do |plur|
          [:one, :zero, :many].each do |amount|
            expect(plur.value[amount]).to eq([plur.key, @fr.code, amount].join(":"))
          end
        end
      end

      it "uses the master text for the english version" do
        get platform, language: "en"
        resource = Android::ResourceFile.parse(response.body)
        locals = resource.localizations
        plurals = locals.select { |l| plural_keys.include?(l.key) }
        expect(plurals.length).to eq(plural_keys.length)
        plural_master_texts.each do |mt|
          plur = locals.detect { |l| l.key == mt.key }
          expect(plur.value[:one]).to eq(mt.one)
          expect(plur.value[:other]).to eq(mt.other)
        end
      end
    end

    describe "arrays" do
      let(:array_master_texts) { %w(planet[0] planet[1] planet[2] door[0] door[1]) }
      before do
        @array_master_texts = array_master_texts.map do |key|
          MasterText.create!(key: key, other: "#{key}", pluralizable: false)
        end
        @array_master_texts.each_with_index do |mt, n|
          LocalizedText.create!({
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
        expect(array.length).to eq(1)
        array = array.first
        items = array.css("item")
        expect(items.length).to eq(3)
        expect(items.map(&:text)).to eq(["planet[0]:ja:0", "planet[1]:ja:1", "planet[2]:ja:2"])

        array = doc.css('string-array[name="door"]')
        expect(array.length).to eq(1)
        array = array.first
        items = array.css("item")
        expect(items.length).to eq(2)
        expect(items.map(&:text)).to eq(["door[0]:ja:3", "door[1]:ja:4"])
      end

      it "includes master texts of arrays for english" do
        get platform, language: "en"
        doc = Nokogiri::XML(response.body)
        array = doc.css('string-array[name="planet"]')
        expect(array.length).to eq(1)
        array = array.first
        items = array.css("item")
        expect(items.length).to eq(3)
        expect(items.map(&:text)).to eq(["planet[0]", "planet[1]", "planet[2]"])

        array = doc.css('string-array[name="door"]')
        expect(array.length).to eq(1)
        array = array.first
        items = array.css("item")
        expect(items.length).to eq(2)
        expect(items.map(&:text)).to eq(["door[0]", "door[1]"])
      end

      it "escapes text within string arrays" do
        key = "escape[0]"
        mt = MasterText.create!(key: key, other: "#{key}", pluralizable: false)
        LocalizedText.create!({
                master_text: mt,
                language: language,
                other: "escape'd \""
            })
        get platform, language: language.code
        doc = Nokogiri::XML(response.body)
        array = doc.css('string-array[name="escape"]')
        item = array.css('item').first
        expect(item.text).to eq("escape\\'d \\\"")
      end
    end

    describe "escaping" do
      before do
        lt = LocalizedText.where(language: language, master_text: master_text).first
        lt.update_attributes(other: text)
        get platform, language: language.code
        doc = Nokogiri::XML(response.body)
        @string = doc.css("string[name='#{master_text.key}']").first.text
      end

      context "apostrophes" do
        let(:text) { "that's crazy" }

        it "are escaped correctly" do
          expect(@string).to eq("that\\'s crazy")
        end
      end

      context "double quotes" do
        let(:text) { "\"that's\" crazy" }

        it "are escaped correctly" do
          expect(@string).to eq("\\\"that\\'s\\\" crazy")
        end
      end
    end
  end

  describe "yaml" do
    let(:platform) { :yaml }

    before do
      get platform, language: language_code
    end

    it "should return a yaml file" do
      expect(response.content_type).to eq("text/yaml; charset=utf-8")
    end
  end
end
