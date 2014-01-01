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
        original_ast && generated_ast && original_ast == generated_ast
      end

      # Return error report
      #
      # @return [String]
      #
      # @api private
      #
      def error_report
        if original_ast && generated_ast
          error_report_with_ast_diff
        else
          error_report_with_parser_error
        end
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

      # Return error report with parser error
      #
      # @return [String]
      #
      # @api private
      #
      def error_report_with_parser_error
        unless original_ast
          return "Parsing of original source failed:\n#{original_source}"
        end

        unless generated_ast
          return "Parsing of generated source failed:\nOriginal-AST:#{original_ast.inspect}\nSource:\n#{generated_source}"
        end

      end

      # Return error report with AST difference
      #
      # @return [String]
      #
      # @api private
      #
      def error_report_with_ast_diff
        diff = Differ.call(
          original_ast.inspect.lines.map(&:chomp),
          generated_ast.inspect.lines.map(&:chomp)
        )
        "#{diff}\nOriginal:\n#{original_source}\nGenerated:\n#{generated_source}"
      end

      # Return generated AST
      #
      # @return [Parser::AST::Node]
      #   if parser was sucessful for generated ast
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def generated_ast
        Preprocessor.run(parse(generated_source))
      rescue Parser::SyntaxError
        nil
      end
      memoize :generated_ast

      # Return original AST
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def original_ast
        Preprocessor.run(parse(original_source))
      rescue Parser::SyntaxError
        nil
      end
      memoize :original_ast

      # Parse source with current ruby
      #
      # @param [String] source
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def parse(source)
        Parser::CurrentRuby.parse(source)
      end

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
