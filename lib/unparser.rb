# frozen_string_literal: true

require 'diff/lcs'
require 'diff/lcs/hunk'
require 'optparse'
require 'parser/current'
require 'set'

require 'unparser/equalizer'
require 'unparser/adamantium'
require 'unparser/adamantium/method_builder'
require 'unparser/abstract_type'

require 'unparser/concord'
require 'unparser/either'
require 'unparser/anima'
require 'unparser/anima/attribute'
require 'unparser/anima/error'

# Library namespace
module Unparser
  # Unparser specific AST builder defaulting to modern AST format
  class Builder < Parser::Builders::Default
    modernize

    def initialize
      super

      self.emit_file_line_as_literals = false
    end
  end

  EMPTY_STRING = ''.freeze
  EMPTY_ARRAY  = [].freeze

  private_constant(*constants(false) - %i[Adamantium AbstractType Anima Concord Either Equalizer Memoizable])

  # Error raised when unparser encounters an invalid AST
  class InvalidNodeError < RuntimeError
    attr_reader :node

    def initialize(message, node)
      super(message)
      @node = node
      freeze
    end
  end # InvalidNodeError

  # Error raised when unparser encounders AST it cannot generate source for that would parse to the same AST.
  class UnsupportedNodeError < RuntimeError
  end # UnsupportedNodeError

  # Unparse an AST (and, optionally, comments) into a string
  #
  # @param [Parser::AST::Node, nil] node
  # @param [Array] comments
  # @param [Encoding, nil] explicit_encoding
  # @param [Set<Symbol>] static_local_variables
  #
  # @return [String]
  #
  # @raise InvalidNodeError
  #   if the node passed is invalid
  #
  # @api public
  #
  # mutant:disable
  # rubocop:disable Metrics/ParameterLists
  def self.unparse(
    node,
    comments:               EMPTY_ARRAY,
    explicit_encoding:      nil,
    static_local_variables: Set.new
  )
    unparse_ast(
      AST.new(
        comments:               comments,
        explicit_encoding:      explicit_encoding,
        node:                   node,
        static_local_variables: static_local_variables
      )
    )
  end
  # rubocop:enable Metrics/ParameterLists

  # Unparse an AST
  #
  # @param [AST] ast
  #
  # @return [String]
  #
  # @raise InvalidNodeError
  #   if the node passed is invalid
  #
  # @raise UnsupportedNodeError
  #   if the node passed is valid but unparser cannot unparse it
  #
  # @api public
  def self.unparse_ast(ast)
    return EMPTY_STRING if ast.node.nil?

    local_variable_scope = AST::LocalVariableScope.new(
      node:                   ast.node,
      static_local_variables: ast.static_local_variables
    )

    Buffer.new.tap do |buffer|
      Emitter::Root.new(
        buffer:               buffer,
        comments:             Comments.new(ast.comments),
        explicit_encoding:    ast.explicit_encoding,
        local_variable_scope: local_variable_scope,
        node:                 ast.node
      ).write_to_buffer
    end.content
  end

  # Unparse AST either
  #
  # @param [AST] ast
  #
  # @return [Either<Exception,String>]
  def self.unparse_ast_either(ast)
    Either.wrap_error(Exception) { unparse_ast(ast) }
  end

  # Unparse AST either
  #
  # @param [AST] ast
  #
  # @return [Either<Exception,String>]
  #
  # mutant:disable
  def self.unparse_validate_ast_either(ast:)
    validation = Validation.from_ast(ast:)

    if validation.success?
      Either::Right.new(validation.generated_source.from_right)
    else
      Either::Left.new(validation)
    end
  end

  # Unparse with validation
  #
  # @param [Parser::AST::Node, nil] node
  # @param [Array] comments
  #
  # @return [Either<Validation,String>]
  def self.unparse_validate(node, comments: EMPTY_ARRAY)
    generated = unparse(node, comments:)
    validation = Validation.from_string(generated)

    if validation.success?
      Either::Right.new(generated)
    else
      Either::Left.new(validation)
    end
  end

  # Parse string into AST
  #
  # @param [String] source
  #
  # @return [Parser::AST::Node, nil]
  def self.parse(source)
    parse_ast(source).node
  end

  # Parse string into either syntax error or AST
  #
  # @param [String] source
  #
  # @return [Either<Exception, (Parser::ASTNode, nil)>]
  def self.parse_ast_either(source)
    Either.wrap_error(Exception) do
      parse_ast(source)
    end
  end

  # Parse source with ast details
  #
  # @param [String] source
  #
  # @return [AST]
  #
  # mutant:disable
  def self.parse_ast(source, static_local_variables: Set.new)
    explicit_encoding = Parser::Source::Buffer.recognize_encoding(source.dup.force_encoding(Encoding::BINARY))
    node, comments = parser.parse_with_comments(buffer(source))

    AST.new(
      comments:               comments,
      explicit_encoding:      explicit_encoding,
      node:                   node,
      static_local_variables: static_local_variables
    )
  end

  # Parser instance that produces AST unparser understands
  #
  # @return [Parser::Base]
  #
  # @api private
  def self.parser
    Parser::CurrentRuby.new(Builder.new).tap do |parser|
      parser.diagnostics.tap do |diagnostics|
        diagnostics.all_errors_are_fatal = true
      end
    end
  end

  # Construct a parser buffer from string
  #
  # @param [String] source
  #
  # @return [Parser::Source::Buffer]
  def self.buffer(source, identification = '(string)')
    Parser::Source::Buffer.new(identification, source: source)
  end
end # Unparser

require 'unparser/node_helpers'
require 'unparser/ast'
require 'unparser/ast/local_variable_scope'
require 'unparser/buffer'
require 'unparser/generation'
require 'unparser/color'
require 'unparser/comments'
require 'unparser/constants'
require 'unparser/diff'
require 'unparser/dsl'
require 'unparser/emitter'
require 'unparser/emitter/alias'
require 'unparser/emitter/args'
require 'unparser/emitter/argument'
require 'unparser/emitter/array'
require 'unparser/emitter/array_pattern'
require 'unparser/emitter/assignment'
require 'unparser/emitter/begin'
require 'unparser/emitter/binary'
require 'unparser/emitter/block'
require 'unparser/emitter/case'
require 'unparser/emitter/case_guard'
require 'unparser/emitter/case_match'
require 'unparser/emitter/cbase'
require 'unparser/emitter/class'
require 'unparser/emitter/const_pattern'
require 'unparser/emitter/def'
require 'unparser/emitter/defined'
require 'unparser/emitter/dstr'
require 'unparser/emitter/dsym'
require 'unparser/emitter/flipflop'
require 'unparser/emitter/float'
require 'unparser/emitter/flow_modifier'
require 'unparser/emitter/for'
require 'unparser/emitter/hash'
require 'unparser/emitter/hash_pattern'
require 'unparser/emitter/hookexe'
require 'unparser/emitter/if'
require 'unparser/emitter/in_match'
require 'unparser/emitter/in_pattern'
require 'unparser/emitter/index'
require 'unparser/emitter/kwbegin'
require 'unparser/emitter/lambda'
require 'unparser/emitter/masgn'
require 'unparser/emitter/match'
require 'unparser/emitter/match_alt'
require 'unparser/emitter/match_as'
require 'unparser/emitter/match_rest'
require 'unparser/emitter/match_var'
require 'unparser/emitter/mlhs'
require 'unparser/emitter/module'
require 'unparser/emitter/op_assign'
require 'unparser/emitter/pin'
require 'unparser/emitter/primitive'
require 'unparser/emitter/range'
require 'unparser/emitter/regexp'
require 'unparser/emitter/repetition'
require 'unparser/emitter/rescue'
require 'unparser/emitter/root'
require 'unparser/emitter/send'
require 'unparser/emitter/simple'
require 'unparser/emitter/string'
require 'unparser/emitter/splat'
require 'unparser/emitter/super'
require 'unparser/emitter/undef'
require 'unparser/emitter/variable'
require 'unparser/emitter/xstr'
require 'unparser/emitter/yield'
require 'unparser/emitter/kwargs'
require 'unparser/emitter/pair'
require 'unparser/emitter/find_pattern'
require 'unparser/emitter/match_pattern'
require 'unparser/emitter/match_pattern_p'
require 'unparser/writer'
require 'unparser/writer/binary'
require 'unparser/writer/dynamic_string'
require 'unparser/writer/regexp'
require 'unparser/writer/resbody'
require 'unparser/writer/rescue'
require 'unparser/writer/send'
require 'unparser/writer/send/attribute_assignment'
require 'unparser/writer/send/binary'
require 'unparser/writer/send/regular'
require 'unparser/writer/send/unary'
require 'unparser/node_details'
require 'unparser/node_details/send'
require 'unparser/cli'

require 'unparser/validation'
# make it easy for zombie
require 'unparser/finalize'
