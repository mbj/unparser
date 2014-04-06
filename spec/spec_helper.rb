# encoding: UTF-8

require 'yaml'
require 'pathname'
require 'unparser'
require 'anima'
require 'morpher'
require 'devtools/spec_helper'

require 'parser/current'
require 'parser/ruby21'

module SpecHelper
  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end

  def strip(source)
    source = source.rstrip
    indent = source.scan(/^\s*/).min_by(&:length)
    source.gsub(/^#{indent}/, '')
  end

end

RSpec.configure do |config|
  config.include(SpecHelper)
  config.extend(SpecHelper)
end
