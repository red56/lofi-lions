require 'spec_helper'


describe LanguagesController do

  let(:valid_session) { {} }
  let(:language) { create(:language) }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Language" do
        expect {
          post :create, {:language => attributes_for(:language)}, valid_session
        }.to change(Language, :count).by(1)
      end
      it "calls Enforcer" do
        LocalizedTextEnforcer.any_instance.should_receive(:language_created)
        post :create, {:language => attributes_for(:language)}, valid_session
      end

      it "assigns a newly created language as @language" do
        post :create, {:language => attributes_for(:language)}, valid_session
        assigns(:language).should be_a(Language)
        assigns(:language).should be_persisted
      end

      it "redirects to the index" do
        post :create, {:language => attributes_for(:language)}, valid_session
        response.should redirect_to(languages_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved language as @language" do
        # Trigger the behavior that occurs when invalid params are submitted
        Language.any_instance.stub(:save).and_return(false)
        post :create, {:language => {  }}, valid_session
        assigns(:language).should be_a_new(Language)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Language.any_instance.stub(:save).and_return(false)
        post :create, {:language => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested language" do
        Language.any_instance.should_receive(:update).with({ "code" => "de" })
        put :update, {:id => language.to_param, :language => { "code" => "de" }}, valid_session
      end

      it "assigns the requested language as @language" do
        put :update, {:id => language.to_param, :language => attributes_for(:language)}, valid_session
        assigns(:language).should eq(language)
      end

      it "redirects to the language" do
        put :update, {:id => language.to_param, :language => attributes_for(:language)}, valid_session
        response.should redirect_to(languages_path)
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Language.any_instance.stub(:save).and_return(false)
      end
      it "assigns the language as @language" do
        put :update, {:id => language.to_param, :language => {  }}, valid_session
        assigns(:language).should eq(language)
      end

      it "re-renders the 'edit' template" do
        put :update, {:id => language.to_param, :language => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { language }
    it "destroys the requested language" do
      expect {
        delete :destroy, {:id => language.to_param}, valid_session
      }.to change(Language, :count).by(-1)
    end

    it "redirects to the languages list" do
      delete :destroy, {:id => language.to_param}, valid_session
      response.should redirect_to(languages_url)
    end
  end

end
