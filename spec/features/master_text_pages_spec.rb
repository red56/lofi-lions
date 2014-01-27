#require('rspec')
require "spec_helper"

describe 'Master Text Pages' do

  describe "index" do
    it "can list several" do
      texts = build_stubbed_list(:master_text, 3)
      MasterText.stub(all: texts)
      visit master_texts_path
    end
    it "links to new" do
      visit master_texts_path
      page.should have_link_to(new_master_text_path)
    end
    it "is linked from home" do
      visit root_path
      page.should have_link_to(master_texts_path)
    end
  end

end