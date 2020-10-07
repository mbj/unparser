require 'spec_helper'
describe 'Unparser on ruby corpus', mutant: false do
  ROOT = Pathname.new(__FILE__).parent.parent.parent.parent

  TMP = ROOT.join('tmp')

  class Project
    include Anima.new(:name, :repo_uri, :repo_ref, :exclude)

    # Perform verification via unparser cli
    #
    # @return [self]
    #   if successful
    #
    # @raise [Exception]
    #   otherwise
    #
    def verify
      checkout
      command = %W(unparser #{repo_path})
      exclude.each do |name|
        command.concat(%W(--ignore #{repo_path.join(name)}))
      end
      system(command) do
        raise "Verifing #{name} failed!"
      end
      self
    end

    # Checkout repository
    #
    # @return [self]
    #
    # @api private
    #
    def checkout
      TMP.mkdir unless TMP.directory?
      if repo_path.exist?
        Dir.chdir(repo_path) do
          system(%w(git pull origin master))
          system(%w(git clean -f -d -x))
        end
      else
        system(%W(git clone #{repo_uri} #{repo_path}))
      end

      Dir.chdir(repo_path) do
        system(%W(git checkout #{repo_ref}))
        system(%w(git reset --hard))
        system(%w(git clean -f -d -x))
      end

      self
    end

  private

    def repo_path
      TMP.join(name)
    end

    def system(arguments)
      return if Kernel.system(*arguments)

      if block_given?
        yield
      else
        raise "System command #{arguments.inspect} failed!"
      end
    end

    transform    = Mutant::Transform
    string       = transform::Primitive.new(String)
    string_array = transform::Array.new(string)
    path         = ROOT.join('spec', 'integrations.yml')

    loader =
      transform::Named.new(
        path.to_s,
        transform::Sequence.new(
          [
            transform::Exception.new(SystemCallError, :read.to_proc),
            transform::Exception.new(YAML::SyntaxError, YAML.method(:safe_load)),
            transform::Array.new(
              transform::Sequence.new(
                [
                  transform::Hash.new(
                     optional: [],
                     required: [
                       transform::Hash::Key.new('exclude',  string_array),
                       transform::Hash::Key.new('name',     string),
                       transform::Hash::Key.new('repo_ref', string),
                       transform::Hash::Key.new('repo_uri', string)
                    ]
                  ),
                  transform::Hash::Symbolize.new,
                  transform::Exception.new(Anima::Error, Project.public_method(:new))
                ]
              )
            )
          ]
        )
      )

    ALL = loader.apply(path).lmap(&:compact_message).from_right
  end

  Project::ALL.each do |project|
    specify "unparsing #{project.name}" do
      project.verify
    end
  end
end
