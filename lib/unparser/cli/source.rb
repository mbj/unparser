# encoding: utf-8

module Unparser
  class CLI
    # Source representation for CLI sources
    class Source
      include AbstractType, Adamantium::Flat, NodeHelpers

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
      def report
        case
        when original_ast && generated_ast
          report_with_ast_diff
        when !original_ast
          report_original
        when !generated_ast
          report_generated
        end
      end
      memoize :report

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

      # Return stripped source
      #
      # @param [String] string
      #
      # @return [String]
      #
      # @api private
      #
      def strip(source)
        source = source.rstrip
        indent = source.scan(/^\s*\n/).first[0..-2]
        source.gsub(/^#{indent}/, '')
      end

      # Return error report for parsing original
      #
      # @return [String]
      #
      # @api private
      #
      def report_original
        strip(<<-MESSAGE)
          Parsing of original source failed:
          #{original_source}
        MESSAGE
      end

      # Return error report for parsing generated
      #
      # @return [String]
      #
      # @api private
      #
      def report_generated
        strip(<<-MESSAGE)
          Parsing of generated source failed:
          Original-AST:
          #{original_ast.inspect}
          Source:
          #{generated_source}
        MESSAGE
      end

      # Return error report with AST difference
      #
      # @return [String]
      #
      # @api private
      #
      def report_with_ast_diff
        strip(<<-MESSAGE)
          #{ast_diff}
          Original-Source:\n#{original_source}
          Original-AST:\n#{original_ast.inspect}
          Generated-Source:\n#{generated_source}
          Generated-AST:\n#{generated_ast.inspect}
        MESSAGE
      end

      # Return ast diff
      #
      # @return [String]
      #
      # @api private
      #
      def ast_diff
        Differ.call(
          original_ast.inspect.lines.map(&:chomp),
          generated_ast.inspect.lines.map(&:chomp)
        )
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
