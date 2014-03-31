require 'strings_file'
class ImportController < ApplicationController
  # FIXME: needs some auth...
  # FIXME: this should only be for the API version
  skip_before_action :verify_authenticity_token

  def auto
    case File.extname(params[:file].original_filename)
    when ".strings"
      ios
    end
  end

  def ios
    begin
      import_ios(params[:file])
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

  protected

  def import_ios(file)
    strings = StringsFile.parse(file)
    strings.each do |localization|
      LocalizedTextEnforcer::MasterTextCrudder.create_or_update!(localization.key, localization.text)
    end
  end

  def import_android(file)
  end
end
