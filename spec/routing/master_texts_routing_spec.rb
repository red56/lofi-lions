require "spec_helper"

describe MasterTextsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/master_texts")).to route_to("master_texts#index")
    end

    it "routes to #new" do
      expect(get("/master_texts/new")).to route_to("master_texts#new")
    end

    it "routes to #show" do
      expect(get("/master_texts/1")).to route_to("master_texts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/master_texts/1/edit")).to route_to("master_texts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/master_texts")).to route_to("master_texts#create")
    end

    it "routes to #update" do
      expect(put("/master_texts/1")).to route_to("master_texts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/master_texts/1")).to route_to("master_texts#destroy", :id => "1")
    end

  end
end
