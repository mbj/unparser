require 'yaml'
require 'pathname'
require 'unparser'
require 'anima'
require 'morpher'
require 'devtools/spec_helper'

require 'parser/current'

module SpecHelper
  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end
end

RSpec.configure do |config|
  config.include(SpecHelper)
  config.extend(SpecHelper)
  config.raise_errors_for_deprecations!
end
