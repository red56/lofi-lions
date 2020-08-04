# frozen_string_literal: true

require "rails_helper"
require "heroku_tool/heroku_targets"

RSpec.describe "heroku_targets.yml" do
  it "is valid (smoke test)" do
    HerokuTool::HerokuTargets.from_file(Rails.root.join("config/heroku_targets.yml"))
  end
end
