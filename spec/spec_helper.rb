require 'yaml'
require 'pathname'
require 'unparser'
require 'anima'
require 'morpher'
require 'devtools/spec_helper'

require 'parser/current'
require 'parser/ruby19'
require 'parser/ruby20'
require 'parser/ruby21'
require 'parser/ruby22'

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
  config.raise_errors_for_deprecations!
end
