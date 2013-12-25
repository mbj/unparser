require 'unparser'
require 'devtools/spec_helper'

require 'parser/ruby21'

module SpecHelper
  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end

  def strip(source)
    return source if source.empty?
    lines = source.lines
    match = /\A[ ]*/.match(lines.first)
    range = match[0].length .. -1
    source = lines.map do |line|
      line[range]
    end.join
    source.chomp
  end

end

RSpec.configure do |config|
  config.include(SpecHelper)
  config.extend(SpecHelper)
end
