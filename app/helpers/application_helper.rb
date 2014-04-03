module ApplicationHelper
  def active_section(section)
    @section == section ? {class:"active"} : {}
  end
end
