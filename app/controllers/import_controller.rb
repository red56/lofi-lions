class ImportController < ApplicationController
  # FIXME: needs some auth...
  # FIXME: this should only be for the API version
  skip_before_action :verify_authenticity_token
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
        format.html { redirect_to master_texts_path, notice: 'Import was successful.' }
        format.json { render text: "OK" }
      end
    rescue => e
      render text: "Error #{e}", status: :unprocessable_entity
      raise # I know this overturns the point of the rescue... but we should actually decide what to look for here
      # not just catch every exception...
    end
  end

  def import_ios(file)
    create_master_texts(IOS::StringsFile.parse(file))
  end

  def import_android(file)
    create_master_texts(Android::ResourceFile.parse(file))
  end

  def import_yaml(file)
    create_master_texts(RailsYamlFormat::YamlFile.parse(file))
  end

  def create_master_texts(localizations)
    Localization.create_master_texts(localizations, @project.id)
  ensure
    localizations.close if localizations
  end

  def find_project
    @project = Project.find(params[:id])
  end
end
