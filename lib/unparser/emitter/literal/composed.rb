module Unparser
  class Emitter
    class Literal

      # Emitter for hash keyvalue pair
      class HashPair < self
        HASHROCKET = ' => '.freeze
        COLON      = ': '.freeze

        handle :pair

        # AST node corresponding to the key
        # 
        # @return [undefined]
        # 
        # @api private
        # 
        alias_method :key, :first_child
        public :key

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          key_emitter = emitter(key)
          
          if key_emitter.is_a?(Primitive::Inspect::Symbol) && key_emitter.safe_without_quotes?
            delimited(children, COLON)
          else
            delimited(children, HASHROCKET)
          end
        end

      end # HashPair

      # Base class for compound literal emitters
      class Compound < self

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          util = self.class
          parentheses(util::OPEN, util::CLOSE) do
            delimited(children, util::DELIMITER)
          end
        end

        # Hash literal emitter
        class Hash < self
          OPEN      = '{'.freeze
          CLOSE     = '}'.freeze
          DELIMITER = ', '.freeze

          handle :hash
        end # Hash

        # Array literal emitter
        class Array < self
          OPEN      = '['.freeze
          CLOSE     = ']'.freeze
          DELIMITER = ', '.freeze

          handle :array
        end # Array

      end # Compound
    end # Literal
  end # Emitter
end # Unparser
