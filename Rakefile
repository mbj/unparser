require 'devtools'
Devtools.init_rake_tasks

class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

Rake.application.load_imports

Rake::Task['metrics:mutant'].overwrite do
  begin
    require 'mutant'
  rescue LoadError
  end
  if defined?(Mutant)
    status = Mutant::CLI.run(%W(--rspec-full -r ./spec/spec_helper.rb ::Unparser))
    unless status.zero?
      fail "Not mutation covered :("
    end
  end
end
