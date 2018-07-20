# frozen_string_literal: true

require "csv"

module Csvable
  extend ActiveSupport::Concern

  class_methods do
    def some_method(scope, batch_size: 50, progress: nil, filepath: nil)
      CsvGenerator.new(self, scope, progress: progress, batch_size: batch_size).generate_or_open(filepath)
    end
  end

  class CsvGenerator
    attr_reader :model_class, :scope, :progress, :batch_size
    def initialize(model_class, scope, progress: nil, batch_size: 50)
      @model_class = model_class
      @scope = scope
      @progress = progress
      @batch_size = batch_size
    end

    def generate_or_open(filepath)
      if filepath
        CSV.open(filepath, "wb") do |csv|
          create(csv)
        end
      else
        CSV.generate do |csv|
          create(csv)
        end
      end
    end

    private

    def create(csv)
      headers(csv)
      # limit memory  consumption by low default batch size
      scope.find_each(batch_size: batch_size) do |item|
        row(csv, item)
      end
    end

    def headers(csv)
      csv << model_class.csv_headers
    end

    def row(csv, item)
      csv << item.to_csv_row
      progress.progress
    end
  end
end
