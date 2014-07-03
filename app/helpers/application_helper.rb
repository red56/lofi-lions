module ApplicationHelper
  def active_section(section)
    @section == section ? {class:"active"} : {}
  end

  def version_details
    "#{deployment_env} v#{version_number} #{deployment_commit_hash}"
  end

  def deployment_env
    Rails.env unless Rails.env.production?
  end

  def deployment_commit_hash
    (ENV['COMMIT_HASH'] ?  "##{ENV['COMMIT_HASH']}" : '(dev)') unless Rails.env.production?
  end

  def version_number
    VERSION
  end
end
