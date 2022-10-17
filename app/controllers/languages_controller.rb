class LanguagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_language, only: [:show, :edit, :update, :destroy]
  before_action :set_languages_section

  # GET /languages
  # GET /languages.json
  def index
    @languages = Language.all
    @languages = @languages.includes(:users) if current_user.is_administrator?
  end

  # GET /languages/1
  # GET /languages/1.json
  def show
  end

  # GET /languages/new
  def new
    @language = Language.new
  end

  # GET /languages/1/edit
  def edit
  end

  # POST /languages
  # POST /languages.json
  def create
    @language = Language.new(language_params)
    respond_to do |format|
      if LocalizedTextEnforcer::LanguageCreator.new(@language).save
        format.html { redirect_to languages_path, notice: "Language was successfully created." }
        format.json { render action: "show", status: :created, location: @language }
      else
        format.html { render action: "new" }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /languages/1
  # PATCH/PUT /languages/1.json
  def update
    respond_to do |format|
      if @language.update(language_params)
        format.html { redirect_to languages_path, notice: "Language was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /languages/1
  # DELETE /languages/1.json
  def destroy
    @language.destroy
    respond_to do |format|
      format.html { redirect_to languages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language
      @language = Language.find_by_code(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def language_params
      params.require(:language).permit(
          :name, :code,
          :pluralizable_label_zero, :pluralizable_label_one, :pluralizable_label_two, :pluralizable_label_few,
          :pluralizable_label_many, :pluralizable_label_other,
          localized_texts_attributes: [:text, :zero, :one, :two, :few, :many, :other, :needs_review, :id]
      )
    end


end
