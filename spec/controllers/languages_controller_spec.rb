require "rails_helper"

describe LanguagesController, type: :controller do
  before { login }
  let(:login) { stubbed_login_as_user }

  context "not logged in" do
    let(:login) { nil }
    it "redirects to sign in page" do
      post :create, params: { language: attributes_for(:language) }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  let(:language) { create(:language) }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Language" do
        expect {
          post :create, params: { language: attributes_for(:language) }
        }.to change(Language, :count).by(1)
      end
      it "calls Enforcer" do
        expect_any_instance_of(LocalizedTextEnforcer).to receive(:language_created)
        post :create, params: { language: attributes_for(:language) }
      end

      it "assigns a newly created language as @language" do
        post :create, params: { language: attributes_for(:language) }
        expect(assigns(:language)).to be_a(Language)
        expect(assigns(:language)).to be_persisted
      end

      it "redirects to the index" do
        post :create, params: { language: attributes_for(:language) }
        expect(response).to redirect_to(languages_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved language as @language" do
        post :create, params: { language: { name: "" } }
        expect(assigns(:language)).to be_a_new(Language)
      end

      it "re-renders the 'new' template" do
        post :create, params: { language: { name: "" } }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested language" do
        put :update, params: { id: language.to_param, language: { "code" => "de" } }
        expect(language.reload.code).to eq("de")
      end

      it "assigns the requested language as @language" do
        put :update, params: { id: language.to_param, language: attributes_for(:language) }
        expect(assigns(:language)).to eq(language)
      end

      it "redirects to the language" do
        put :update, params: { id: language.to_param, language: attributes_for(:language) }
        expect(response).to redirect_to(languages_path)
      end
    end

    describe "with invalid params" do
      it "assigns the language as @language" do
        put :update, params: { id: language.to_param, language: { name: "" } }
        expect(assigns(:language)).to eq(language)
      end

      it "re-renders the 'edit' template" do
        put :update, params: { id: language.to_param, language: { name: "" } }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { language }
    it "destroys the requested language" do
      expect {
        delete :destroy, params: { id: language.to_param }
      }.to change(Language, :count).by(-1)
    end

    it "redirects to the languages list" do
      delete :destroy, params: { id: language.to_param }
      expect(response).to redirect_to(languages_url)
    end
  end
end
