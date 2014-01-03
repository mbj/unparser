require 'spec_helper'

describe Unparser::AST do
  describe '.local_variable_scope' do
    subject { described_class.local_variable_scope(node) }

    let(:expected_lvars) do
      container = Object.new
      binding = container.instance_eval(source)
      binding.eval('local_variables').to_set
    end

    def root
      Parser::CurrentRuby.parse(source)
    end

    def find_parent_path(root, node)
      parents = []
      current = node
      while current != root
        parent = Unparser::AST::Enumerator.new(root).find do |candidate|
          candidate.children.include?(current)
        end
        raise "Cannot find parend for #{current.inspect} in #{root.inspect}" unless parent
        current = parent
        parents << parent
      end
      parents
    end

    def node
      parent_path = find_parent_path(root, s(:send, nil, :binding))
      p parent_path.map(&:type)
      node = parent_path.find { |node| Unparser::Constants::LOCAL_VARIABLE_RESET_BOUNDARY_NODES.include?(node.type) }
      p node
      raise "No enclosing lvar scoping node could be found" unless node
      node
    end

    context 'with empty parent tree' do
      let(:node)           { s(:empty) }
      let(:expected_lvars) { Set.new   }

      it { should eql(expected_lvars) }
    end

    context 'with same nodes' do
      let(:root)           { s(:empty) }
      let(:node)           { root      }
      let(:expected_lvars) { Set.new   }
    end

    context 'when preceeded by lvasgn in differend lvar scope through block' do
      let(:source) do
        <<-RUBY
          class Container
            [].each { |foo| }
            [1].map { |bar| binding }.first
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with lvasgn in differend lvar scope through sibling def' do
      let(:source) do
        <<-RUBY
          class Container
            def foo
              bar = baz
            end
            binding
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with lvasgn in differend lvar scope through sibling defs' do
      let(:source) do
        <<-RUBY
          class Container
            def self.foo
              bar = baz
            end
            binding
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with lvsasgn in differend lvar scope in parent' do

      let(:source) do
        <<-RUBY
          class Container
            bar = :baz

            def foo
              binding
            end

            new.foo
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with required argument in differend lvar scope' do

      let(:source) do
        <<-RUBY
          class Container
            def foo(bar)
              def foo
                binding
              end

              foo
            end

            new.foo(:bar)
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with required argument in same lvar scope' do
      let(:source) do
        <<-RUBY
          class Container
            def foo(foo)
              binding
            end
            new.foo(:bar)
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with optarg in same lvar scope' do
      let(:source) do
        <<-RUBY
          class Container
            def foo(foo = :bar)
              binding
            end
            new.foo
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with lvasgn in same lvar scope before node' do
      let(:source) do
        <<-RUBY
          class Container
            foo = :other
            binding
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with lvasgn in same lvar scope after node' do
      let(:source) do
        <<-RUBY
          class Container
            class << self
              attr_accessor :stored_binding
            end

            def foo
              self.class.stored_binding = binding
              bar = :other
            end

            new.foo

            stored_binding

          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end

    context 'with blockargs in same lvar scope' do
      let(:source) do
        <<-RUBY
          class Container
            [1].map do |item|
              binding
            end.first
          end
        RUBY
      end

      it { should eql(expected_lvars) }
    end
  end
end
