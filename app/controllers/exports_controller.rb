class ExportsController < ApplicationController
  before_filter :load_language
  before_action :find_project

  def android
    export
  end

  def ios
    export
  end

  def yaml
    export
  end

  protected

  def export(platform = params[:action])
    exporter = BaseExporter.class_for(platform).new(@language, @project)
    headers["X-Path"] = exporter.path
    send_data exporter.body, type: exporter.content_type, disposition: "inline", filename: ::File.basename(exporter.path)
  end

  def load_language
    code = params[:language]
    @language = Language.where(code: code).first
    return load_language_fallback(code) if @language.nil?
  end

  def load_language_fallback(code)
    if code == "en"
      @language = Language.en if code == "en"
    else
      render text: "Language #{code} not found", status: 404
      return false
    end
  end

  def find_project
    @project = Project.find(params[:id])
  end
end
