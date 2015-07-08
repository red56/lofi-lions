class ProjectsController < ApplicationController

  def show
    @project = Project.find(params[:id])
    @active_tab = :overview
  end

end
