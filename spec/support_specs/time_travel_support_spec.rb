# frozen_string_literal: true

require "rails_helper"

RSpec.describe "time travel" do
  it "travels" do
    travel_to(DateTime.parse("2022-10-01 04:00"))
    expect(Time.zone.today).to eq(Date.parse("2022-10-01"))
  end

  it "travels back" do
    expect(Time.zone.today).to be > Date.parse("2022-10-20")
  end
end
