class ViewsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_view, only: [:show, :edit, :update, :destroy]
  before_action :set_view_tab
  before_action :find_project, only: [:new, :index]

  # GET /views
  # GET /views.json
  def index
    @views = @project.views.all
  end

  # GET /views/1
  # GET /views/1.json
  def show
  end

  # GET /views/new
  def new
    @view = @project.views.new
  end

  # GET /views/1/edit
  def edit
  end

  # POST /views
  # POST /views.json
  def create
    @view = View.new(view_params)

    respond_to do |format|
      if @view.save
        format.html { redirect_to @view, notice: "View was successfully created." }
        format.json { render action: "show", status: :created, location: @view }
      else
        format.html { render action: "new" }
        format.json { render json: @view.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /views/1
  # PATCH/PUT /views/1.json
  def update
    respond_to do |format|
      if @view.update(view_params)
        format.html { redirect_to @view, notice: "View was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @view.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /views/1
  # DELETE /views/1.json
  def destroy
    @view.destroy
    respond_to do |format|
      format.html { redirect_to views_url }
      format.json { head :no_content }
    end
  end

  private
    def find_view
      @view = View.find(params[:id])
      @project = @view.project
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def view_params
      params.require(:view).permit(:name, :comments, :keys, :project_id)
    end

    def find_project
      @project = Project.find(params[:project_id])
    end
end
