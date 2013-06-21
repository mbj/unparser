require 'unparser'
require 'devtools/spec_helper'

require 'parser/ruby21'

module SpecHelper
  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end
end

RSpec.configure do |config|
  config.include(SpecHelper)
  config.extend(SpecHelper)
end
