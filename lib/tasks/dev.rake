# frozen_string_literal: true

namespace :dev do
  task dev_data: :environment do
    fail("Should only do in development!") unless (Rails.env.development?)
  end

  task staging_data: :environment do
    fail("Should only do in staging!") unless (Rails.env.staging?)
  end

  desc "raise an error (for testing purposes)"
  task raise: :environment do
    fail "raising at #{Time.now}"
  end
end
