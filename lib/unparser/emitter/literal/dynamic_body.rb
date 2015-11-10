module Unparser
  class Emitter
    class Literal

      # Emitter for dynamic bodies
      class DynamicBody < self

        OPEN = '#{'.freeze
        CLOSE = '}'.freeze

        # Emitter for interpolated nodes
        class Interpolation < self

          handle :interpolated

          children :subject

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            write(OPEN)
            visit_plain(subject)
            write(CLOSE)
          end

        end

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          # 2 adjacent str nodes may indicate that there was a line continuation
          # in the original source
          children.reduce(nil) do |previous, current|
            emit_segment(current, previous)
          end
        end

        # Emit segment
        #
        # @param [Parser::AST::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_segment(node, prev_node)
          if node.type == :str
            if prev_node && prev_node.type == :str &&
               different_lines?(prev_node, node)
              # emit line continuation
              write('"' + WS + '\\')
              nl
              write('"')
            end
            emit_str_segment(node)
          else
            emit_interpolated_segment(node)
          end
          node
        end

        pairs = Parser::Lexer::ESCAPES.invert.map do |key, value|
          [key, "\\#{value}"] unless key.eql?(WS)
        end.compact

        pairs << ['#{', '\#{']

        ESCAPES = ::Hash[pairs]

        REPLACEMENTS = ::Regexp.union(ESCAPES.keys)

        # Emit str segment
        #
        # @param [Parser::AST::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_str_segment(node)
          util = self.class
          string = node.children.first
          segment = string
                    .gsub(REPLACEMENTS, ESCAPES)
                    .gsub(util::DELIMITER, util::REPLACEMENT)
          write(segment)
        end

        # Emit interpolated segment
        #
        # @param [Parser::AST::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_interpolated_segment(node)
          visit_parentheses(node, OPEN, CLOSE)
        end

        # Dynamic string body
        class String < self

          handle :dyn_str_body

          DELIMITER   = '"'.freeze
          REPLACEMENT = '\"'.freeze

        end # String

        # Dynamic regexp body
        class Regexp < self

          handle :dyn_regexp_body

          DELIMITER   = '/'.freeze
          REPLACEMENT = '\/'.freeze

        end # Regexp

        # Dynamic regexp body
        class ExecuteString < self

          handle :dyn_xstr_body

          DELIMITER   = '`'.freeze
          REPLACEMENT = '\`'.freeze

        end # ExecuteString

      end # DynamicBody
    end # Literal
  end # Emitter
end # Unparser
