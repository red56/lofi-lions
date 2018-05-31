# frozen_string_literal: true
module ExternalLibraries
  module Errors
    # an error response from an external library's api
    class ApiError < ::StandardError
      include ::Bugsnag::MetaData
      attr_accessor :bugsnag_meta_data

      def initialize(library_ident, method, path, data, response_code, body)
        super "#{library_ident} error - path:#{path}, response:#{response_code}, body:#{body} "
        self.bugsnag_meta_data = {
          request: {
            method: method,
            path: path,
            data: data
          },
          response: {
            code: response_code,
            body: body
          }
        }
      end

      def notify_bugsnag
        Bugsnag.notify(self)
      end
    end
  end
end
