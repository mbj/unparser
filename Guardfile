# encoding: utf-8

ENV['GUARD'] = '1'

guard :bundler do
  watch('Gemfile')
end

guard :rspec, :all_on_start => false, :all_after_pass => false, :cmd => 'bundle exec rspec --fail-fast --seed 1' do
  # run all specs if the spec_helper or supporting files files are modified
  watch('spec/spec_helper.rb')                      { 'spec/unit' }
  watch(%r{\Aspec/(?:lib|support|shared)/.+\.rb\z}) { 'spec/unit' }

  # run unit specs if associated lib code is modified
  watch(%r{\Alib/(.+)\.rb\z})                                         { 'spec' }
  watch("lib/#{File.basename(File.expand_path('../', __FILE__))}.rb") { 'spec' }

  # run a spec if it is modified
  watch(%r{\Aspec/(?:unit|integration)/.+_spec\.rb\z})
end
