# frozen_string_literal: true

module Unparser
  class Emitter
    class Literal

      # Base class for dynamic literal emitters
      class Dynamic < self

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          segments.each_with_index do |children, index|
            visit_segment(children, index)
          end
        end

        def visit_segment(children, index)
          util = self.class

          write(' ') unless index.zero?

          parentheses(util::OPEN, util::CLOSE) do
            visit_body(children)
          end
        end

        NO_PARENS = %i[ivar cvar gvar].to_set.freeze

        BOUNDARIES =
          [
            %i(str str),
            %i(dstr str),
            %i(str dstr),
            %i(dstr dstr)
          ]

        def segments
          children.chunk_while do |left, right|
            !BOUNDARIES.any?([left.type, right.type])
          end
        end
        memoize :segments

        def visit_body(children)
          children.each do |child|
            if child.type.equal?(:str)
              write(child.children.first.inspect[1..-2])
            else
              visit_dynamic(child)
            end
          end
        end

        def visit_dynamic(child)
          if NO_PARENS.include?(child.type)
            write('#')
            visit(child)
            return
          end

          if child.type.equal?(:dstr)
            visit_body(child.children)
            return
          end

          parentheses('#{', '}') do
            if child.type.equal?(:begin) && child.children.one?
              visit(child.children.first)
            else
              visit(child)
            end
          end
        end

        # Dynamic string literal emitter
        class String < self

          OPEN = CLOSE = '"'.freeze
          handle :dstr

        end # String

        # Dynamic executable string
        class Execute < self

          OPEN = CLOSE = '`'.freeze
          handle :xstr

          def dispatch
            if segments.one?
              visit_segment(segments.first, 0)
              return
            end

            write("<<-`HERE`\n")

            segments.each do |children|
              children.each do |child|
                if child.type.equal?(:str)
                  write(child.children.first)
                else
                  fail
                end
              end
            end

            write("HERE\n")
          end
        end

        # Dynamic symbol literal emitter
        class Symbol < self

          OPEN = ':"'.freeze
          CLOSE = '"'.freeze

          handle :dsym

        end # Symbol
      end # Dynamic
    end # Literal
  end # Emitter
end # Unparser
