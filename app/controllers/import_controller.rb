require 'strings_file'
require 'android_resource_file'
class ImportController < ApplicationController
  # FIXME: needs some auth...
  # FIXME: this should only be for the API version
  skip_before_action :verify_authenticity_token

  def auto
    case File.extname(params[:file].original_filename)
      when ".strings"
        ios
      when ".xml"
        android
    end
  end

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

  protected

  def import_response
    begin
      yield
      respond_to do |format|
        format.html { redirect_to master_texts_path, notice: 'Import was successful.' }
        format.json { render text: "OK" }
      end
    rescue => e
      respond_to do |format|
        # format.html { render action: 'import' }
        format.json { render text: "Error", status: :unprocessable_entity }
      end
    end
  end

  def import_ios(file)
    localizations = StringsFile.parse(file)
    Localization.create_master_texts(localizations)
  end

  def import_android(file)
    localizations = AndroidResourceFile.parse(file)
    Localization.create_master_texts(localizations)
  end
end
