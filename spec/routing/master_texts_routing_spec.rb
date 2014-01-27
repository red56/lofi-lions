require "spec_helper"

describe MasterTextsController do
  describe "routing" do

    it "routes to #index" do
      get("/master_texts").should route_to("master_texts#index")
    end

    it "routes to #new" do
      get("/master_texts/new").should route_to("master_texts#new")
    end

    it "routes to #show" do
      get("/master_texts/1").should route_to("master_texts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/master_texts/1/edit").should route_to("master_texts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/master_texts").should route_to("master_texts#create")
    end

    it "routes to #update" do
      put("/master_texts/1").should route_to("master_texts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/master_texts/1").should route_to("master_texts#destroy", :id => "1")
    end

  end
end
