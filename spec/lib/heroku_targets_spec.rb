# frozen_string_literal: true

require "rails_helper"
require "heroku_tool/heroku_targets"

RSpec.describe "heroku_targets.yml" do
  it "is valid (smoke test)" do
    pending "create a heroku_targets for this to be tested" unless Rails.root.join("config/heroku_targets.yml").exist?
    HerokuTool::HerokuTargets.from_file(Rails.root.join("config/heroku_targets.yml"))
  end
end
