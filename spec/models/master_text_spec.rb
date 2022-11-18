# frozen_string_literal: true

require "rails_helper"

RSpec.describe MasterText, type: :model do
  describe "validations" do
    let(:master_text) { build(:master_text) }

    it "basically works" do
      expect(master_text).to be_valid
    end

    it "requires key" do
      master_text.key = nil
      expect(master_text).not_to be_valid
    end

    it "requires key" do
      master_text.key = ""
      expect(master_text).not_to be_valid
    end

    it "requires unique key" do
      master_text.save!
      new_master_text = MasterText.new(key: master_text.key)
      expect(new_master_text).not_to be_valid
    end

    it "requires text" do
      master_text.text = nil
      expect(master_text).not_to be_valid
    end

    it "requires text" do
      master_text.text = ""
      expect(master_text).not_to be_valid
    end

    context "pluralizable" do
      let(:master_text) { build(:master_text, pluralizable: true) }

      it "basically works" do
        expect(master_text).to be_valid
      end

      it "requires key" do
        master_text.key = nil
        expect(master_text).not_to be_valid
      end

      it "requires key" do
        master_text.key = ""
        expect(master_text).not_to be_valid
      end

      it "requires unique key" do
        master_text.save!
        new_master_text = MasterText.new(key: master_text.key)
        expect(new_master_text).not_to be_valid
      end

      it "requires other" do
        master_text.other = ""
        expect(master_text).not_to be_valid
      end

      it "requires a project" do
        master_text.project_id = nil
        expect(master_text).not_to be_valid
      end
    end
  end

  context "pluralizable" do
    let(:master_text) { build(:master_text, pluralizable: true) }

    it "can't return text" do
      expect {
        master_text.text
      }.to raise_error(/when pluralizable/)
    end
  end

  describe "text_changed?" do
    shared_examples_for "shared_text_changed" do
      it "is false when key changing" do
        master_text.key = "flong"
        expect(master_text.text_changed?).to be_falsey
      end

      it "is false when nothing changing" do
        expect(master_text.text_changed?).to be_falsey
      end

      it "is true when pluralizable" do
        master_text.pluralizable = !master_text.pluralizable
        expect(master_text.text_changed?).to be_truthy
      end
    end
    context "when unpluralized" do
      let(:master_text) { create(:master_text, pluralizable: false) }

      it "is true when text changing" do
        master_text.text = "flong"
        expect(master_text.text_changed?).to be_truthy
      end

      include_examples "shared_text_changed"
    end

    context "when pluralized" do
      let(:master_text) { create(:master_text, pluralizable: true) }

      it "is true when one changing" do
        master_text.one = "flong"
        expect(master_text.text_changed?).to be_truthy
      end

      it "is true when other changing" do
        master_text.other = "flong"
        expect(master_text.text_changed?).to be_truthy
      end

      include_examples "shared_text_changed"
    end
  end

  context "#key" do
    let(:existing) { create :master_text, project: create(:project) }

    it "must be unique" do
      expect(build(:master_text, key: existing.key, project: existing.project)).not_to be_valid
    end

    it "only unique in same project" do
      expect(build(:master_text, key: existing.key, project: create(:project))).to be_valid
    end
  end

  describe "#markdown?" do
    subject { master_text }

    let(:master_text) { build(:master_text, format: format) }

    context "markdown" do
      let(:format) { MasterText::MARKDOWN_FORMAT }

      it { is_expected.to be_markdown }
    end

    context "plain" do
      let(:format) { MasterText::PLAIN_FORMAT }

      it { is_expected.not_to be_markdown }
    end
  end

  describe "word count" do
    it "counts nothing" do
      master_text = build(:master_text, text: nil)
      expect(master_text.send(:calculate_word_count)).to eq(0)
      master_text = build(:master_text, text: "")
      expect(master_text.send(:calculate_word_count)).to eq(0)
    end

    it "counts a word" do
      master_text = build(:master_text, text: "Oh.")
      expect(master_text.send(:calculate_word_count)).to eq(1)
    end

    it "counts some words" do
      master_text = build(:master_text, text: "Oh, so there you are Mr Jones.")
      expect(master_text.send(:calculate_word_count)).to eq(7)
    end

    it "counts some words in paragraphs or weird spacing" do
      text = <<~TEXT
              Oh, so there you are Mr Jones.
        We have been expecting you
        \t\tFor some time!
      TEXT
      master_text = build(:master_text, text: text)
      expect(master_text.send(:calculate_word_count)).to eq(15)
    end

    context "when pluralizable" do
      it "counts nothing" do
        master_text = build(:master_text, one: nil, other: nil, pluralizable: true)
        expect(master_text.send(:calculate_word_count)).to eq(0)
      end

      it "counts one" do
        master_text = build(:master_text, one: "a dog", other: "many dogs", pluralizable: true)
        expect(master_text.send(:calculate_word_count)).to eq(4)
      end

      it "counts several" do
        master_text = build(:master_text, one: "this is a carrot", other: "these are some carrots", pluralizable: true)
        expect(master_text.send(:calculate_word_count)).to eq(8)
      end
    end

    it "is stored on save" do
      master_text = create(:master_text, text: "many")
      expect { master_text.update(text: "many dogs are lovely.") }.to change { master_text.reload[:word_count] }.from(1).to(4)
    end
  end

  describe "scope with_keys" do
    let(:project) { create :project }
    let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "### 1. Name\n\nOne  \n\n Two\n\nThree") }
    let!(:other_master_text) { create(:master_text, project: project, key: "something_else") }

    it "works with regexp" do
      expect(project.master_texts.with_keys(/terms_c_\d+_md/)).to contain_exactly(master_text)
    end

    it "works with single string" do
      expect(project.master_texts.with_keys("terms_c_01_md")).to contain_exactly(master_text)
    end

    it "works with two strings" do
      expect(project.master_texts.with_keys("terms_c_01_md", "something_else")).to contain_exactly(master_text, other_master_text)
    end
  end

  describe "md_to_paragraphs!" do
    let(:project) { create :project }
    let!(:project_language) { create(:project_language, project: project) }
    let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "### 1. Name\n\nOne  \n\n Two\n\nThree") }
    let!(:localized_text) { create(:localized_text, master_text: master_text, project_language: project_language, text: "### 1. Nom\n\nUn\n\nDeux \n\n Trois") }
    let(:created_master_text_p1) { project.master_texts.where(key: "terms_c_01_p1").first }

    it "is renamed" do
      expect { master_text.md_to_paragraphs! }.to change { master_text.reload.key }.to("ΩΩΩ_terms_c_01_md")
    end

    it "changes master text counts" do
      expect { master_text.md_to_paragraphs! }.to change { project.master_texts.count }.from(1).to(1 + 4)
    end

    context "with views" do
      let(:view) { create(:view, project: project) }
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "Name\nOne\nTwo\nThree", views: [view]) }

      it "copies them" do
        master_text.md_to_paragraphs!
        expect(created_master_text_p1.views).to eq([view])
      end
    end

    context "with comment" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "Name\nOne\nTwo\nThree", comment: "whatevs") }

      it "copies them" do
        master_text.md_to_paragraphs!
        expect(created_master_text_p1.comment).to eq("whatevs")
      end
    end

    context "with only one paragraph" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "One") }

      it "won't change it" do
        original_key = master_text.key
        expect { master_text.md_to_paragraphs! }.not_to change { project.master_texts.count }
        expect(master_text.reload.key).to eq(original_key)
      end
    end

    it "can change localized text counts" do
      expect { master_text.md_to_paragraphs! }.to change { project.localized_texts.count }.from(1).to(1 + 4)
    end

    context "with wrong number of localized_text paras" do
      let!(:localized_text) { create(:localized_text, master_text: master_text, project_language: project_language, text: "### 1. Nom\n\nUn\n\nDeux") }

      it "raises" do
        expect {
          expect { master_text.md_to_paragraphs! }.to raise_error(/wrong/)
        }.not_to change { project.localized_texts.count }.from(1)
      end
    end

    it "names keys as expected" do
      expect {
        master_text.md_to_paragraphs!
      }.to change { project.master_texts.reload.map(&:key) }
        .from(contain_exactly("terms_c_01_md"))
        .to contain_exactly("ΩΩΩ_terms_c_01_md", "terms_c_01_p1", "terms_c_01_p2", "terms_c_01_p3", "terms_c_01_p4")
    end

    it "returns new master texts" do
      expect(master_text.md_to_paragraphs!.map(&:key)).to eq(%w[terms_c_01_p1 terms_c_01_p2 terms_c_01_p3 terms_c_01_p4])
    end

    it "can take base_key to change keys of new master texts" do
      expect(master_text.md_to_paragraphs!(base_key: "flong").map(&:key)).to eq(%w[flong_p1 flong_p2 flong_p3 flong_p4])
    end
  end

  describe "md_to_heading_and_body" do
    let(:project) { create :project }
    let!(:project_language) { create(:project_language, project: project) }
    let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "### 1. Name\n\nOne  \n\n Two\n\nThree") }
    let!(:localized_text) { create(:localized_text, master_text: master_text, project_language: project_language, text: "### 1. Nom\n\nUn\n\nDeux \n\n Trois") }
    let(:created_master_text_heading) { project.master_texts.where(key: "terms_c_01_heading").first }
    let(:created_master_text_body) { project.master_texts.where(key: "terms_c_01_text").first }

    it "is renamed" do
      expect { master_text.md_to_heading_and_text! }.to change { master_text.reload.key }.to("ΩΩΩ_terms_c_01_md")
    end

    it "changes master text counts" do
      expect { master_text.md_to_heading_and_text! }.to change { project.master_texts.count }.from(1).to(1 + 2)
    end

    context "with views" do
      let(:view) { create(:view, project: project) }
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "One\nTwo", views: [view]) }

      it "copies them" do
        master_text.md_to_heading_and_text!
        expect(created_master_text_heading.views).to eq([view])
        expect(created_master_text_body.views).to eq([view])
      end
    end

    context "with comment" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "One\nTwo", comment: "whatevs") }

      it "copies them" do
        master_text.md_to_heading_and_text!
        expect(created_master_text_heading.comment).to eq("whatevs")
        expect(created_master_text_body.comment).to eq("whatevs")
      end
    end

    context "with only one paragraph" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "One") }

      it "won't change it" do
        original_key = master_text.key
        expect { master_text.md_to_heading_and_text! }.not_to change { project.master_texts.count }
        expect(master_text.reload.key).to eq(original_key)
      end
    end

    it "can change localized text counts" do
      expect { master_text.md_to_heading_and_text! }.to change { project.localized_texts.count }.from(1).to(1 + 2)
    end

    it "names keys as expected" do
      expect {
        master_text.md_to_heading_and_text!
      }.to change { project.master_texts.reload.map(&:key) }
        .from(contain_exactly("terms_c_01_md"))
        .to contain_exactly("ΩΩΩ_terms_c_01_md", "terms_c_01_heading", "terms_c_01_text")
    end

    it "returns new master texts" do
      expect(master_text.md_to_heading_and_text!.map(&:key)).to eq(%w[terms_c_01_heading terms_c_01_text])
    end

    it "can take base_key to change keys of new master texts" do
      expect(master_text.md_to_heading_and_text!(base_key: "flong").map(&:key)).to eq(%w[flong_heading flong_text])
    end

    context "with heading" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "### 1. Name\ntwo") }
      let!(:localized_text) { create(:localized_text, master_text: master_text, project_language: project_language, text: "### 1. Nom\n\nUn\n\nDeux \n\n Trois") }

      it "strips heading / number" do
        master_text.md_to_heading_and_text!
        expect(created_master_text_heading.text).to eq("Name")
        expect(created_master_text_heading.localized_texts.first.text).to eq("Nom")
      end
    end

    context "with bullets" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "Heading\n* one\ntwo\n* three") }
      let!(:localized_text) { create(:localized_text, master_text: master_text, project_language: project_language, text: "### 1. Nom\n\n* Un\n\nDeux \n\n* Trois") }

      it "strips bullets" do
        master_text.md_to_heading_and_text!
        expect(created_master_text_body.text).to eq("one\n\ntwo\n\nthree")
        expect(created_master_text_body.localized_texts.first.text).to eq("Un\n\nDeux\n\nTrois")
      end
    end
  end

  describe "split_to_sections" do
    let(:project) { create :project }
    let!(:project_language) { create(:project_language, project: project) }
    let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: en_text) }
    let(:en_text) {
      <<~EN_TEXT
        Section 1 Para 1

        ### Section 2 Heading
        Section 2 Para 1
        ### Section 3 Heading
        Section 3 Para 1
        Section 3 Para 2
        ### Section 4 Heading
      EN_TEXT
    }
    let(:de_text) {
      <<~DE_TEXT
        Abschnitt 1 Abs 1

        ### Abschnitt 2 Überschrift
        Abschnitt 2 Abs 1
        ### Abschnitt 3 Überschrift
        Abschnitt 3 Abs 1
        Abschnitt 3 Abs 2
        ### Abschnitt 4 Überschrift
      DE_TEXT
    }
    let!(:localized_text) { create(:localized_text, master_text: master_text, project_language: project_language, text: de_text) }
    let(:created_master_text_s2_p1) { project.master_texts.find_by(key: "terms_c_01_s2_p1") }

    it "is renamed" do
      expect { master_text.split_to_sections }.to change { master_text.reload.key }.to("ΩΩΩ_terms_c_01_md")
    end

    it "changes master text counts" do
      expect { master_text.split_to_sections }.to change { project.master_texts.count }.from(1).to(1 + 7)
    end

    context "with views" do
      let(:view) { create(:view, project: project) }
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: en_text, views: [view]) }

      it "copies them" do
        master_text.split_to_sections
        expect(created_master_text_s2_p1.views).to eq([view])
      end
    end

    context "with comment" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: en_text, comment: "whatevs") }

      it "copies them" do
        master_text.split_to_sections
        expect(created_master_text_s2_p1.comment).to eq("whatevs")
      end
    end

    context "with only one paragraph" do
      let!(:master_text) { create(:master_text, project: project, key: "terms_c_01_md", text: "One") }

      it "won't change it" do
        original_key = master_text.key
        expect { master_text.split_to_sections }.not_to change { project.master_texts.count }
        expect(master_text.reload.key).to eq(original_key)
      end
    end

    it "can change localized text counts" do
      expect { master_text.split_to_sections }.to change { project.localized_texts.count }.from(1).to(1 + 7)
    end

    context "with wrong number of localized_text paras" do
      let!(:localized_text) { create(:localized_text, master_text: master_text, project_language: project_language, text: "### 1. Nom\n\nUn\n\nDeux") }

      it "raises" do
        expect {
          expect { master_text.split_to_sections }.to raise_error(/wrong/)
        }.not_to change { project.localized_texts.count }.from(1)
      end
    end

    it "names keys as expected" do
      expect {
        master_text.split_to_sections
      }.to change { project.master_texts.reload.map(&:key) }
        .from(contain_exactly("terms_c_01_md"))
        .to contain_exactly("ΩΩΩ_terms_c_01_md", "terms_c_01_s1_p1", "terms_c_01_s2_heading", "terms_c_01_s2_p1", "terms_c_01_s3_heading", "terms_c_01_s3_p1", "terms_c_01_s3_p2", "terms_c_01_s4_heading")
    end

    it "returns new master texts" do
      expect(master_text.split_to_sections.map(&:key)).to eq(%w[terms_c_01_s1_p1 terms_c_01_s2_heading terms_c_01_s2_p1 terms_c_01_s3_heading terms_c_01_s3_p1 terms_c_01_s3_p2 terms_c_01_s4_heading])
    end

    it "can take base_key to change keys of new master texts" do
      expect(master_text.split_to_sections(base_key: "flong").map(&:key)).to eq(%w[flong_s1_p1 flong_s2_heading flong_s2_p1 flong_s3_heading flong_s3_p1 flong_s3_p2 flong_s4_heading])
    end
  end

  context "as textable" do
    include_examples "behaves as textable" do
      let(:factory_name) { :master_text }
    end
  end
end
