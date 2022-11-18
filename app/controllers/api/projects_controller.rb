# frozen_string_literal: true

class Api::ProjectsController < ApplicationController
  # FIXME: needs some auth...
  # FIXME: this should only be for the API version
  skip_before_action :verify_authenticity_token
  before_action :find_language
  before_action :find_project

  def export
    exporter = BaseExporter.class_for(params[:platform]).new(@language, @project)
    headers["X-Path"] = exporter.path
    send_data exporter.body, type: exporter.content_type, disposition: "inline", filename: ::File.basename(exporter.path)
  end

  def import
    import_texts(params[:file], params[:platform] || auto_platform())
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: "Import was successful." }
      format.json { render json: "OK" }
    end
    # rescue => e
    #   render json: "Error #{e}", status: :unprocessable_entity
  end

  protected

  def auto_platform
    case File.extname(params[:file].original_filename)
    when ".strings"
      :ios
    when ".xml"
      :android
    when ".yml"
      :yaml
    end
  end

  def redirect_path
    if @language.is_master_text?
      master_texts_path
    else
      language_texts_path(@language)
    end
  end

  def import_texts(file, platform)
    localizations = BaseParsedFile.class_for(platform).parse(file)
    if @language.is_master_text?
      Localization.create_master_texts(localizations, @project)
    else
      Localization.create_localized_texts(@language, localizations, @project.id)
    end
  ensure
    localizations.close if localizations
  end

  def find_language
    @language = case params[:code]
                when nil, Language.for_master_texts.code
                  Language.for_master_texts
                when "xx"
                  Language.xx_for_testing
                else
                  Language.find_by(code: params[:code])
                end

    render json: "Language #{params[:code].inspect} not found", status: 404 unless @language
  end

  def find_project
    @project = Project.find_by_slug(params[:id]) || Project.find(params[:id])
  end
end
