# encoding: utf-8

require 'rails_helper'

describe Api::ProjectsController, :type => :controller do

  describe "export" do
    let(:project) { create :project }
    let(:language) { create :language, code: 'ja' }
    let(:language_code) { language.code } #ensures that language is in db
    let!(:project_language) { create :project_language, project: project, language: language }
    shared_context "with a bunch of precreated stuff" do
      let!(:languages) { [create(:language, code: 'es'), language] }
      let!(:project_languages) { languages.map { |lang| create(:project_language, project: project, language: lang) } }
      let!(:project_language) { project_languages.detect { |plang| plang.project == project && plang.language == language } }
      let(:keys) { %w(title welcome complete) }
      let(:master_text) { MasterText.where(key: 'title', project_id: project.id).first }
      let!(:master_texts) { keys.map { |key| MasterText.create!(key: key, other: key.capitalize, project: project) } }

      def ensure_localised_texts(project_languages)
        project_languages.each do |project_language|
          project_language.project.master_texts.each do |mt|
            LocalizedText.create!(master_text: mt, project_language: project_language,
                other: [mt.key, project_language.language.code].join(":"))
          end
        end
      end

      before { ensure_localised_texts(project_languages) }
    end

    let(:request) { get :export, platform: platform, code: language_code, id: project.slug }
    describe "common" do
      it "returns a 404 if the language is uknown" do
        get :export, platform: :android, code: "xx", id: project.slug
        expect(response.status).to eq(404)
      end
    end
    describe "ios" do
      let(:platform) { :ios }
      let(:body) { response.body[1..-1].encode(Encoding::UTF_8) }

      describe "translated texts" do
        include_context "with a bunch of precreated stuff"

        it "should return a zip file" do
          request
          expect(response.content_type).to eq("application/octet-stream; charset=#{Encoding::UTF_16.name}")
        end

        it "has a relative filename in the headers" do
          request
          expect(response.header["X-Path"]).to eq("ja.lproj/Localizable.strings")
        end

        it "should start with a UTF-16LE BOM" do
          request
          bom = response.body.bytes[0..1]
          expect(bom).to eq("\xFF\xFE".bytes)
        end

        it "should have an encoding of UTF16LE" do
          request
          expect(response.body.encoding).to eq(Encoding::UTF_16LE)
        end

        it "should fallback to the english version" do
          request
          # create mt with no localizations
          mt = MasterText.create!(key: "missing", other: "Missing", project: project)
          LocalizedText.create!(master_text: mt, project_language: project_language, other: "")
          get :export, platform: platform, code: language_code, id: project.slug
          file = IOS::StringsFile.parse(StringIO.new(body))
          local = file.localizations.detect { |l| l.key == mt.key }
          expect(local.value).to eq(mt.other)
        end

        it "should order the keys alphabetically" do
          request
          keys = body.lines.map { |line| line.split(/ *= */).first }
          sorted = keys.dup.sort
          expect(keys).to eq(sorted)
        end
      end

      describe "escaping" do
        let(:master_text) { create :master_text, project: project, key: 'title' }
        before do
          create(:localized_text, project_language: project_language, master_text: master_text, other: text)
        end

        context "double quotes" do
          let(:text) { "\"that's\"\ncrazy" }

          it "are escaped correctly" do
            request
            expect(body).to match(/^"title" *= *"\\"that's\\"\\ncrazy";$/)
          end

          # round trip
          it "survive re-import" do
            request
            file = IOS::StringsFile.parse(StringIO.new(body))
            local = file.localizations.detect { |l| l.key == master_text.key }
            expect(local.value).to eq(text)
          end
        end
      end

      describe "english texts" do

        let(:language_code) { 'en' }
        it "uses fallbacks to produce the english version" do
          request
          expect(response.status).to eq(200)
        end

        context "with texts" do
          include_context "with a bunch of precreated stuff"

          let(:language_code) { 'en' }

          it "uses the master text values" do
            request
            file = IOS::StringsFile.parse(StringIO.new(response.body))
            master_texts.each do |mt|
              local = file.localizations.detect { |l| l.key == mt.key }
              expect(local.value).to eq(mt.other)
            end
          end
        end
      end
    end

    describe "android" do
      let(:platform) { :android }

      describe "singular" do
        before do
          get :export, platform: platform, code: language_code, id: project.slug
        end

        it "should return a zip file" do
          expect(response.content_type).to eq("text/xml")
        end

        it "has a relative filename in the headers" do
          expect(response.header["X-Path"]).to eq("res/values-ja/strings.xml")
        end

        context "with texts" do
          include_context "with a bunch of precreated stuff"

          it "returns a valid xml document for a language" do
            request
            # io = StringIO.new(response.body)
            resource = Android::ResourceFile.parse(response.body)
            locals = resource.localizations
            expect(locals.map(&:key).sort).to eq(keys.sort)
            keys.each do |key|
              string = locals.detect { |l| l.key == key }
              expect(string.text).to eq("#{key}:ja")
            end
          end
        end

        it "should fallback to the english version" do
          # create mt with no localizations
          mt = MasterText.create!(key: "missing", other: "Missing", project: project)
          LocalizedText.create!(master_text: mt, project_language: project_language, other: "")
          get :export, platform: platform, code: language_code, id: project.slug
          file = Android::ResourceFile.parse(response.body)
          local = file.localizations.detect { |l| l.key == mt.key }
          expect(local.value).to eq(mt.other)
        end
      end

      describe "plurals" do
        include_context "with a bunch of precreated stuff"

        let(:plural_keys) { %w(cow duck) }
        let(:plural_master_texts) { plural_keys.map do |key|
          MasterText.create!(key: key, one: key.capitalize, other: "#{key.capitalize}s", pluralizable: true,
              project: project)
        end
        }

        let(:french) { Language.create!(code: "fr", name: "French", pluralizable_label_zero: "zero",
            pluralizable_label_one: "one", pluralizable_label_many: "many") }
        let(:french_project_language) { create(:project_language, language: french, project: project) }
        before do
          master_texts.concat(plural_master_texts)
          master_texts.each do |mt|
            case mt.pluralizable?
              when true
                LocalizedText.create!({
                        master_text: mt,
                        project_language: french_project_language,
                        one: [mt.key, french.code, "one"].join(":"),
                        zero: [mt.key, french.code, "zero"].join(":"),
                        many: [mt.key, french.code, "many"].join(":")
                    })
              when false
                LocalizedText.create!(master_text: mt, project_language: french_project_language, other: [mt.key, french.code].join(":"))
            end
          end
        end

        it "includes the plural forms in the xml" do
          get :export, platform: platform, code: french.code, id: project.slug
          resource = Android::ResourceFile.parse(response.body)
          locals = resource.localizations
          plurals = locals.select { |l| plural_keys.include?(l.key) }
          expect(plurals.length).to eq(plural_keys.length)
          plurals.each do |plur|
            [:one, :zero, :many].each do |amount|
              expect(plur.value[amount]).to eq([plur.key, french.code, amount].join(":"))
            end
          end
        end

        it "uses the master text for the english version" do
          get :export, platform: platform, code: "en", id: project.slug
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
            MasterText.create!(key: key, other: "#{key}", pluralizable: false, project: project)
          end
          @array_master_texts.each_with_index do |mt, n|
            LocalizedText.create!({
                    master_text: mt,
                    project_language: project_language,
                    other: [mt.key, language.code, "#{n}"].join(":")
                })
          end
        end

        it "includes array forms in the xml" do
          get :export, platform: platform, code: language.code, id: project.slug
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
          get :export, platform: platform, code: "en", id: project.slug
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
          mt = MasterText.create!(key: key, other: "#{key}", pluralizable: false, project: project)
          LocalizedText.create!({
                  master_text: mt,
                  project_language: project_language,
                  other: "escape'd \""
              })
          get :export, platform: platform, code: language.code, id: project.slug
          doc = Nokogiri::XML(response.body)
          array = doc.css('string-array[name="escape"]')
          item = array.css('item').first
          expect(item.text).to eq("escape\\'d \\\"")
        end
      end

      describe "escaping" do
        let(:master_text) { create :master_text, project: project, key: 'title' }
        before do
          create(:localized_text, project_language: project_language, master_text: master_text, other: text)
          request
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
        get :export, platform: platform, code: language_code, id: project.slug
      end

      it "should return a yaml file" do
        expect(response.content_type).to eq("text/yaml; charset=utf-8")
      end

      context 'with multiple projects' do
        let(:other_project) { create :project }
        let(:master_texts) {
          super() + [other_projects_master_text]
        }
        let(:other_projects_master_text) {
          create :master_text, key: "my-special-key", project: other_project
        }
        include_context "with a bunch of precreated stuff"

        it "should include keys from selected project" do
          request
          expect(response.body).to include(keys.first)
        end
        it "shouldn't include text from other project" do
          request
          expect(response.body).not_to include(other_projects_master_text.key)
        end
      end

      it "should order the keys alphabetically" do
        keys = YAML.load(response.body).values.first.keys
        sorted = keys.dup.sort
        expect(keys).to eq(sorted)
      end

    end
  end
end
