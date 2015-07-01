require 'rails_helper'


describe MasterTextsController, :type => :controller do

  before { login }
  let(:login) { stubbed_login_as_user }

  context "not logged in" do
    let(:login) { nil }
    it "redirects to sign in page" do
      post :create, {:master_text => attributes_for(:master_text)}
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  let(:master_text) { create(:master_text) }

  describe "POST create" do

    describe "with valid params" do
      it "creates a new MasterText" do
        expect {
          post :create, {:master_text => attributes_for(:master_text)}
        }.to change(MasterText, :count).by(1)
      end

      it "assigns a newly created master_text as @master_text" do
        post :create, {:master_text => attributes_for(:master_text)}
        expect(assigns(:master_text)).to be_a(MasterText)
        expect(assigns(:master_text)).to be_persisted
      end

      it "redirects to the created master_text" do
        post :create, {:master_text => attributes_for(:master_text)}
        expect(response).to redirect_to(master_texts_path)
      end


    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved master_text as @master_text" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(MasterText).to receive(:save).and_return(false)
        post :create, {:master_text => {"key" => "invalid value"}}
        expect(assigns(:master_text)).to be_a_new(MasterText)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(MasterText).to receive(:save).and_return(false)
        post :create, {:master_text => {"key" => "invalid value"}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    before { master_text }
    describe "with valid params" do
      it "updates the requested master_text" do
        expect_any_instance_of(MasterText).to receive(:assign_attributes).with({"key" => "MyString"})
        put :update, {:id => master_text.to_param, :master_text => {"key" => "MyString"}}
      end

      it "assigns the requested master_text as @master_text" do
        put :update, {:id => master_text.to_param, :master_text => attributes_for(:master_text)}
        expect(assigns(:master_text)).to eq(master_text)
      end

      it "redirects to the master_text" do
        put :update, {:id => master_text.to_param, :master_text => attributes_for(:master_text)}
        expect(response).to redirect_to(master_texts_path)
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(MasterText).to receive(:save).and_return(false)
      end
      it "assigns the master_text as @master_text" do
        put :update, {:id => master_text.to_param, :master_text => {"key" => "invalid value"}}
        expect(assigns(:master_text)).to eq(master_text)
      end

      it "re-renders the 'edit' template" do
        put :update, {:id => master_text.to_param, :master_text => {"key" => "invalid value"}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { master_text }
    it "destroys the requested master_text" do
      expect {
        delete :destroy, {:id => master_text.to_param}
      }.to change(MasterText, :count).by(-1)
    end

    it "redirects to the master_texts list" do
      delete :destroy, {:id => master_text.to_param}
      expect(response).to redirect_to(master_texts_url)
    end
  end

end
