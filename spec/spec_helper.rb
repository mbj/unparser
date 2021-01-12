require 'anima'
require 'mutant'
require 'pathname'
require 'rspec/its'
require 'timeout'
require 'unparser'
require 'yaml'

require 'parser/current'

RSpec.configuration.around(file_path: %r{spec/unit}) do |example|
  Timeout.timeout(5, &example)
end

RSpec.shared_examples_for 'a command method' do
  it 'returns self' do
    should equal(object)
  end
end

RSpec.shared_examples_for 'an idempotent method' do
  it 'is idempotent' do
    first = subject
    fail 'RSpec not configured for threadsafety' unless RSpec.configuration.threadsafe?
    mutex    = __memoized.instance_variable_get(:@mutex)
    memoized = __memoized.instance_variable_get(:@memoized)

    mutex.synchronize { memoized.delete(:subject) }
    should equal(first)
  end
end

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
