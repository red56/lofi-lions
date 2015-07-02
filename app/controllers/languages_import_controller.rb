class LanguagesImportController < ApplicationController
  # FIXME: needs some auth...
  # FIXME: this should only be for the API version
  skip_before_action :verify_authenticity_token
  before_action :find_language

  def ios
    import_response do
      import_ios(params[:file])
    end
  end

  def android
    import_response do
      import_android(params[:file])
    end
  end

  def yaml
    import_response do
      import_yaml(params[:file])
    end
  end

  protected

  def import_response
    begin
      yield
      respond_to do |format|
        format.html { redirect_to language_texts_path(@language), notice: 'Import was successful.' }
        format.json { render text: "OK" }
      end
    rescue => e
      render text: "Error #{e}", status: :unprocessable_entity
    end
  end

  def import_ios(file)
    create_localized_texts(IOS::StringsFile.parse(file))
  end

  def import_android(file)
    create_localized_texts(Android::ResourceFile.parse(file))
  end

  def import_yaml(file)
    create_localized_texts(RailsYamlFormat::YamlFile.parse(file))
  end

  def create_localized_texts(localizations)
    Localization.create_localized_texts(@language, localizations)
  ensure
    localizations.close if localizations
  end

  def find_language
    @language = Language.find_by_code(params[:id])
    if @language.nil?
      render text: "No such language as #{params[:id]}", status: :unprocessable_entity
      return false
    end
  end
end