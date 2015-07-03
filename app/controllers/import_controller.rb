class ImportController < ApplicationController
  # FIXME: needs some auth...
  # FIXME: this should only be for the API version
  skip_before_action :verify_authenticity_token
  before_action :find_language
  before_action :find_project

  def auto
    case File.extname(params[:file].original_filename)
      when ".strings"
        ios
      when ".xml"
        android
      when ".yml"
        yaml
    end
  end

  def ios
    import(:ios)
  end

  def android
    import(:android)
  end

  def yaml
    import(:yaml)
  end

  protected

  def import(platform)
    import_texts(params[:file], platform)
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: 'Import was successful.' }
      format.json { render text: "OK" }
    end
    # rescue => e
    #   render text: "Error #{e}", status: :unprocessable_entity
  end

  def redirect_path
    if @language
      language_texts_path(@language)
    else
      master_texts_path
    end
  end

  def import_texts(file, platform)
    localizations = BaseParsedFile.class_for(platform).parse(file)
    if @language
      Localization.create_localized_texts(@language, localizations, @project.id)
    else
      Localization.create_master_texts(localizations, @project.id)
    end
  ensure
    localizations.close if localizations
  end

  def find_language
    @language = Language.find_by_code(params[:code])
    if params[:code] && @language.nil?
      render text: "No such language as #{params[:code]}", status: :unprocessable_entity
      return false
    end
  end

  def find_project
    @project = Project.find(params[:id])
  end

end