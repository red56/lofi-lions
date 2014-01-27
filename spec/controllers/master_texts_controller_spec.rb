require 'spec_helper'


describe MasterTextsController do


  # minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication)
  let(:valid_session) { {} }
  let(:master_text) { create(:master_text) }


  describe "POST create" do
    describe "with valid params" do
      it "creates a new MasterText" do
        expect {
          post :create, {:master_text => attributes_for(:master_text)}, valid_session
        }.to change(MasterText, :count).by(1)
      end

      it "assigns a newly created master_text as @master_text" do
        post :create, {:master_text => attributes_for(:master_text)}, valid_session
        assigns(:master_text).should be_a(MasterText)
        assigns(:master_text).should be_persisted
      end

      it "redirects to the created master_text" do
        post :create, {:master_text => attributes_for(:master_text)}, valid_session
        response.should redirect_to(MasterText.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved master_text as @master_text" do
        # Trigger the behavior that occurs when invalid params are submitted
        MasterText.any_instance.stub(:save).and_return(false)
        post :create, {:master_text => {"key" => "invalid value"}}, valid_session
        assigns(:master_text).should be_a_new(MasterText)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        MasterText.any_instance.stub(:save).and_return(false)
        post :create, {:master_text => {"key" => "invalid value"}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before { master_text }
    describe "with valid params" do
      it "updates the requested master_text" do
        # Assuming there are no other master_texts in the database, this
        # specifies that the MasterText created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        MasterText.any_instance.should_receive(:update).with({"key" => "MyString"})
        put :update, {:id => master_text.to_param, :master_text => {"key" => "MyString"}}, valid_session
      end

      it "assigns the requested master_text as @master_text" do
        put :update, {:id => master_text.to_param, :master_text => attributes_for(:master_text)}, valid_session
        assigns(:master_text).should eq(master_text)
      end

      it "redirects to the master_text" do
        put :update, {:id => master_text.to_param, :master_text => attributes_for(:master_text)}, valid_session
        response.should redirect_to(master_text)
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        MasterText.any_instance.stub(:save).and_return(false)
      end
      it "assigns the master_text as @master_text" do
        put :update, {:id => master_text.to_param, :master_text => {"key" => "invalid value"}}, valid_session
        assigns(:master_text).should eq(master_text)
      end

      it "re-renders the 'edit' template" do
        put :update, {:id => master_text.to_param, :master_text => {"key" => "invalid value"}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { master_text }
    it "destroys the requested master_text" do
      expect {
        delete :destroy, {:id => master_text.to_param}, valid_session
      }.to change(MasterText, :count).by(-1)
    end

    it "redirects to the master_texts list" do
      delete :destroy, {:id => master_text.to_param}, valid_session
      response.should redirect_to(master_texts_url)
    end
  end

end
