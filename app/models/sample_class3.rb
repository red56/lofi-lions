class SampleClass3 < ActiveRecord::Base
  attr_accessor :some_field, :other_field

  include Csvable

  def self.to_csv(scope, progress: nil, filepath: nil)
    # click "some_method" and then Refactor this and inline
    some_method(scope, progress: progress, filepath: filepath)
  end

  def to_csv_row
    [
      some_field,
      other_field,
    ]
  end

  def self.csv_headers
    [
      "Some field",
      "Other field"
    ]
  end
end
