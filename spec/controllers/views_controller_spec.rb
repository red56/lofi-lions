require 'rails_helper'

describe ViewsController, :type => :controller do
  before { login }
  let(:login) { stubbed_login_as_developer}

  # This should return the minimal set of attributes required to create a valid
  # View. As you add validations to View, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:view)
  }

  let(:invalid_attributes) {
    {view: {}}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ViewsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all views as @views" do
      view = View.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:views)).to eq([view])
    end
  end

  describe "GET show" do
    it "assigns the requested view as @view" do
      view = View.create! valid_attributes
      get :show, {:id => view.to_param}, valid_session
      expect(assigns(:view)).to eq(view)
    end
  end

  describe "GET new" do
    it "assigns a new view as @view" do
      get :new, {}, valid_session
      expect(assigns(:view)).to be_a_new(View)
    end
  end

  describe "GET edit" do
    it "assigns the requested view as @view" do
      view = View.create! valid_attributes
      get :edit, {:id => view.to_param}, valid_session
      expect(assigns(:view)).to eq(view)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new View" do
        expect {
          post :create, {:view => valid_attributes}, valid_session
        }.to change(View, :count).by(1)
      end

      it "assigns a newly created view as @view" do
        post :create, {:view => valid_attributes}, valid_session
        expect(assigns(:view)).to be_a(View)
        expect(assigns(:view)).to be_persisted
      end

      it "redirects to the created view" do
        post :create, {:view => valid_attributes}, valid_session
        expect(response).to redirect_to(View.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved view as @view" do
        post :create, {:view => invalid_attributes}, valid_session
        expect(assigns(:view)).to be_a_new(View)
      end

      it "re-renders the 'new' template" do
        post :create, {:view => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) { attributes_for(:view) }

      it "updates the requested view" do
        view = View.create! valid_attributes
        put :update, {:id => view.to_param, :view => new_attributes}, valid_session
        expect(view.reload.name).to eq(new_attributes[:name])
      end

      it "assigns the requested view as @view" do
        view = View.create! valid_attributes
        put :update, {:id => view.to_param, :view => valid_attributes}, valid_session
        expect(assigns(:view)).to eq(view)
      end

      it "redirects to the view" do
        view = View.create! valid_attributes
        put :update, {:id => view.to_param, :view => valid_attributes}, valid_session
        expect(response).to redirect_to(view)
      end
    end

    describe "with invalid params" do
      it "assigns the view as @view" do
        view = View.create! valid_attributes
        put :update, {:id => view.to_param, :view => invalid_attributes}, valid_session
        expect(assigns(:view)).to eq(view)
      end

      # it "re-renders the 'edit' template" do
      #   view = View.create! valid_attributes
      #   put :update, {:id => view.to_param, :view => invalid_attributes}, valid_session
      #   expect(response).to render_template("edit")
      # end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested view" do
      view = View.create! valid_attributes
      expect {
        delete :destroy, {:id => view.to_param}, valid_session
      }.to change(View, :count).by(-1)
    end

    it "redirects to the views list" do
      view = View.create! valid_attributes
      delete :destroy, {:id => view.to_param}, valid_session
      expect(response).to redirect_to(views_url)
    end
  end

end
