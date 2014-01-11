# encoding: UTF-8

module Unparser
  # Helpers for stripping source
  module StripHelper

    INDENT_PATTERN = /^\s*/.freeze

    # String indentation of source away
    #
    # @param [String] source
    #
    # @return [String]
    #
    # @api private
    #
    def strip(source)
      indent = source.rstrip.scan(INDENT_PATTERN).min_by(&:length)
      source.gsub(/^#{indent}/, '')
    end

  end # StripHelper
end # Unparser
