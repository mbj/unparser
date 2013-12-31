# encoding: utf-8

module Unparser
  class CLI
    # Source representation for CLI sources
    class Source
      include AbstractType, Adamantium::Flat

      # Test if source could be unparsed successfully
      #
      # @return [true]
      #   if source could be unparsed successfully
      #
      # @return [false]
      #
      # @api private
      #
      def success?
        original_ast == generated_ast
      end

      # Return error report
      #
      # @return [String]
      #
      # @api private
      #
      def error_report
        diff = Differ.call(
          original_ast.inspect.lines.map(&:chomp),
          generated_ast.inspect.lines.map(&:chomp)
        )
        "#{diff}\nOriginal:\n#{original_source}\nGenerated:\n#{generated_source}"
      end
      memoize :error_report

    private

      # Return generated source
      #
      # @return [String]
      #
      # @api private
      #
      def generated_source
        Unparser.unparse(original_ast)
      end
      memoize :generated_source

      # Return generated AST
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def generated_ast
        Preprocessor.run(Parser::CurrentRuby.parse(generated_source))
      end
      memoize :generated_ast

      # Return original AST
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def original_ast
        Preprocessor.run(Parser::CurrentRuby.parse(original_source))
      end
      memoize :original_ast

      # CLI source from string
      class String < self
        include Concord.new(:original_source)

        # Return identification
        #
        # @return [String]
        #
        # @api private
        #
        def identification
          '(string)'
        end

      end # String

      # CLI source from file
      class File < self
        include Concord.new(:file_name)

        # Return identification
        #
        # @return [String]
        #
        # @api private
        #
        def identification
          "(#{file_name})"
        end

      private

        # Return original source
        #
        # @return [String]
        #
        # @api private
        #
        def original_source
          ::File.read(file_name)
        end
        memoize :original_source

      end # File
    end # Source
  end # CLI
end # Unparser
