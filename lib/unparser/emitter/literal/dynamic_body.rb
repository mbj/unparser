module Unparser
  class Emitter
    class Literal

      # Emitter for dynamic bodies
      class DynamicBody < self

        OPEN = '#{'.freeze
        CLOSE = '}'.freeze

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          children.each do |node|
            emit_segment(node)
          end
        end

        # Emit segment
        #
        # @param [Parser::Node] node
        #
        # @return [undefined]
        #
        # @api private
        # 
        def emit_segment(node)
          if node.type == :str
            emit_str_segment(node)
            return
          end
          emit_interpolated_segment(node)
        end

        # Emit str segment
        #
        # @param [Parser::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_str_segment(node)
          util = self.class
          write(node.children.first.gsub(util::DELIMITER, util::REPLACEMENT))
        end

        # Emit interpolated segment
        #
        # @param [Parser::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_interpolated_segment(node)
          parentheses(OPEN, CLOSE) { visit(node) }
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
          REPLACEMENT = '/'.freeze

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
