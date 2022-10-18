require "rails_helper"


describe MasterTextsController, type: :controller do

  before { login }
  let(:login) { stubbed_login_as_user }
  let(:project) { create :project }
  let(:master_text_attributes) { attributes_for(:master_text, project_id: project.id) }


  context "not logged in" do
    let(:login) { nil }
    it "redirects to sign in page" do
      post :create, params: { master_text: master_text_attributes }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  let(:master_text) { create(:master_text, project: project) }

  describe "POST create" do

    describe "with valid params" do
      it "creates a new MasterText" do
        expect {
          post :create, params: { master_text: master_text_attributes }
        }.to change(MasterText, :count).by(1)
      end

      it "assigns a newly created master_text as @master_text" do
        post :create, params: { master_text: master_text_attributes }
        expect(assigns(:master_text)).to be_a(MasterText)
        expect(assigns(:master_text)).to be_persisted
      end

      it "redirects to the created master_text" do
        post :create, params: { master_text: master_text_attributes }
        expect(response).to redirect_to(project_master_texts_path(project))
      end


    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved master_text as @master_text" do
        post :create, params: { master_text: {"key" => ""} }
        expect(assigns(:master_text)).to be_a_new(MasterText)
      end

      it "re-renders the 'new' template" do
        post :create, params: { master_text: {"key" => ""} }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    before { master_text }
    describe "with valid params" do
      it "updates the requested master_text" do
        put :update, params: { id: master_text.to_param, master_text: {"key" => "MyString"} }
        expect(master_text.reload.key).to eq("MyString")
      end

      it "assigns the requested master_text as @master_text" do
        put :update, params: { id: master_text.to_param, master_text: master_text_attributes }
        expect(assigns(:master_text)).to eq(master_text)
      end

      it "redirects to the master_text" do
        put :update, params: { id: master_text.to_param, master_text: master_text_attributes }
        expect(response).to redirect_to(project_master_texts_path(project))
      end
    end

    describe "with invalid params" do
      it "assigns the master_text as @master_text" do
        put :update, params: { id: master_text.to_param, master_text: {"key" => ""} }
        expect(assigns(:master_text)).to eq(master_text)
      end

      it "re-renders the 'edit' template" do
        put :update, params: { id: master_text.to_param, master_text: {"key" => ""} }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { master_text }
    it "destroys the requested master_text" do
      expect {
        delete :destroy, params: { id: master_text.to_param }
      }.to change(MasterText, :count).by(-1)
    end

    it "redirects to the master_texts list" do
      delete :destroy, params: { id: master_text.to_param }
      expect(response).to redirect_to(project_master_texts_path(project))
    end
  end

end
