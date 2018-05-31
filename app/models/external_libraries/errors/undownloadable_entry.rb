# frozen_string_literal: true
module ExternalLibraries
  module Errors
    class UndownloadableEntry < StandardError
      def initialize(entry, url = entry.original_url, response_code = nil)
        super "UndownloadableEntry #{entry.id}; #{url}; code : #{response_code};"
        @entry = entry
        @url = url
        @response_code = response_code
      end

      def notify_bugsnag
        Bugsnag.notify(self) do |notif|
          notif.add_tab(:undownloadable, entry: { id: @entry.id },
                                         url: @url,
                                         code: @response_code)
        end
      end
    end
  end
end
