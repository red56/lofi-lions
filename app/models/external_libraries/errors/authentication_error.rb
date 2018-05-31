# frozen_string_literal: true
module ExternalLibraries
  module Errors
    class AuthenticationError < StandardError
      include ::Bugsnag::MetaData
      attr_accessor :bugsnag_meta_data

      def initialize(library_ident, method: nil, path: nil, data: nil, response_code: nil, body: nil)
        return super("#{library_ident} AuthenticationError") unless method
        # then must provide path, data, response_code, body
        super("#{library_ident} AuthenticationError  - path:#{path}, response:#{response_code}, body:#{body}")
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
    end
  end
end
