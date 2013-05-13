module Unparser
  class Emitter
    class Literal

      # Emitter for dynamic bodies
      class DynamicBody < self

        # Artificial intermediary node to cleanup 
        # dynamic literal generation
        handle :dynbody

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
            emit_string_segment(node)
            return
          end

          emit_interpolated_segment(node)
        end

        OPEN = '#{'.freeze
        CLOSE = '}'.freeze

        # Emit interpolated segment
        #
        # @param [Parser::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_interpolated_segment(node)
          parentheses(OPEN, CLOSE) do
            visit(node)
          end
        end

        STRING_SEGMENT_RANGE = (1..-2).freeze

        # Emit string segment
        #
        # @param [Parser::Node] node
        #
        # @return [undefined]
        #
        # @api rpivate
        #
        def emit_string_segment(node)
          write(node.children.first.inspect[STRING_SEGMENT_RANGE])
        end
      end # DynamicBody
    end # Literal
  end # Emitter
end # Unparser
