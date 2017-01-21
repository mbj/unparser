module Unparser
  class CLI
    # Source representation for CLI sources
    class Source
      include AbstractType, Adamantium::Flat, NodeHelpers

      # Source state generated after first unparse
      class Generated
        include Concord::Public.new(:source, :ast, :error)

        # Test if source was generated successfully
        #
        # @return [Boolean]
        #
        # @api private
        #
        def success?
          !error
        end

        # Build generated source
        #
        # @param [Parser::AST::Node]
        #
        # @api private
        #
        def self.build(ast)
          source = Unparser.unparse(ast)
          new(source, ast, nil)
        rescue => exception
          new(nil, ast, exception)
        end
      end

      # Test if source could be unparsed successfully
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        generated.success? && original_ast && generated_ast && original_ast.eql?(generated_ast)
      end

      # Return error report
      #
      # @return [String]
      #
      # @api private
      #
      def report
        if original_ast && generated_ast
          report_with_ast_diff
        elsif !original_ast
          report_original
        elsif !generated.success?
          report_unparser
        elsif !generated_ast
          report_generated
        else
          raise
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
      def generated
        Source::Generated.build(original_ast)
      end
      memoize :generated

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
        indent = source.scan(/^\s*/).first
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

      # Report unparser bug
      #
      # @return [String]
      #
      # @api private
      #
      def report_unparser
        message = ['Unparsing parsed AST failed']
        error = generated.error
        message << error
        error.backtrace.take(20).each(&message.method(:<<))
        message << 'Original-AST:'
        message << original_ast.inspect
        message.join("\n")
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
          Original-source:
          #{original_source}
          Original-AST:
          #{original_ast.inspect}
          Source:
          #{generated.source}
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
          Generated-Source:\n#{generated.source}
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
        generated.success? && Preprocessor.run(parse(generated.source))
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

      # Source passed in as node
      class Node < self
        include Concord.new(:original_ast)

        # Return original source
        #
        # @return [String]
        #
        # @api private
        #
        def original_source
          Unparser.unparse(original_ast)
        end
        memoize :original_source
      end # Node

    end # Source
  end # CLI
end # Unparser
