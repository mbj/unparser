module Unparser

  # Emitter base class
  #
  # buggy, argument values are sends to self
  # rubocop:disable CircularArgumentReference
  class Emitter
    include Adamantium::Flat, AbstractType, Constants, NodeHelpers
    include Concord.new(:node, :parent)
    extend DSL

    # Registry for node emitters
    REGISTRY = {} # rubocop:disable MutableConstant

    NOINDENT = [:rescue, :ensure].to_set.freeze

    DEFAULT_DELIMITER = ', '.freeze

    CURLY_BRACKETS = IceNine.deep_freeze(%w({ }))

    module Unterminated
      def terminated?
        false
      end
    end

    module Terminated
      def terminated?
        true
      end
    end

    module LocalVariableRoot

      # Return local variable root
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def local_variable_scope
        AST::LocalVariableScope.new(node)
      end

      def self.included(descendant)
        descendant.class_eval do
          memoize :local_variable_scope
        end
      end

    end # LocalVariableRoot

    # Return local variable root
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def local_variable_scope
      parent.local_variable_scope
    end

    # Return assigned lvars
    #
    # @return [Array<Symbol>]
    #
    # @api private
    #
    abstract_method :local_variables

    # Return node type
    #
    # @return [Symbol]
    #
    # @api private
    #
    def node_type
      node.type
    end

    # Register emitter for type
    #
    # @param [Symbol] type
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.handle(*types)
      types.each do |type|
        REGISTRY[type] = self
      end
    end
    private_class_method :handle

    # Trigger write to buffer
    #
    # @return [self]
    #
    # @api private
    #
    def write_to_buffer
      emit_comments_before if buffer.fresh_line?
      dispatch
      comments.consume(node)
      emit_eof_comments if parent.is_a?(Root)
      self
    end
    memoize :write_to_buffer

    # Emit node
    #
    # @return [self]
    #
    # @api private
    #
    def self.emit(*arguments)
      new(*arguments).write_to_buffer
    end

    # Return emitter
    #
    # @return [Emitter]
    #
    # @api private
    #
    def self.emitter(node, parent)
      type = node.type
      klass = REGISTRY.fetch(type) do
        raise ArgumentError, "No emitter for node: #{type.inspect}"
      end
      klass.new(node, parent)
    end

    # Dispatch node
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :dispatch

    # Test if node is emitted as terminated expression
    #
    # @return [Boolean]
    #
    # @api private
    #
    abstract_method :terminated?

  protected

    # Return buffer
    #
    # @return [Buffer] buffer
    #
    # @api private
    #
    def buffer
      parent.buffer
    end
    memoize :buffer, freezer: :noop

    # Return comments
    #
    # @return [Comments] comments
    #
    # @api private
    #
    def comments
      parent.comments
    end
    memoize :comments, freezer: :noop

  private

    # Emit contents of block within parentheses
    #
    # @return [undefined]
    #
    # @api private
    #
    def parentheses(open = M_PO, close = M_PC)
      write(open)
      yield
      write(close)
    end

    # Visit node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit_plain(node)
      emitter = emitter(node)
      emitter.write_to_buffer
    end

    # Visit ambiguous node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit(node)
      emitter = emitter(node)
      conditional_parentheses(!emitter.terminated?) do
        emitter.write_to_buffer
      end
    end

    # Visit within parentheses
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit_parentheses(node, *arguments)
      parentheses(*arguments) do
        visit_plain(node)
      end
    end

    # Call block in optional parentheses
    #
    # @param [true, false] flag
    #
    # @return [undefined]
    #
    # @api private
    #
    def conditional_parentheses(flag)
      if flag
        parentheses { yield }
      else
        yield
      end
    end

    # Return emitter for node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Emitter]
    #
    # @api private
    #
    def emitter(node)
      self.class.emitter(node, self)
    end

    # Emit delimited body
    #
    # @param [Enumerable<Parser::AST::Node>] nodes
    # @param [String] delimiter
    #
    # @return [undefined]
    #
    # @api private
    #
    def delimited_plain(nodes, delimiter = DEFAULT_DELIMITER)
      delimited(nodes, delimiter, &method(:visit_plain))
    end

    # Emit delimited body
    #
    # @param [Enumerable<Parser::AST::Node>] nodes
    # @param [String] delimiter
    #
    # @return [undefined]
    #
    # @api private
    #
    def delimited(nodes, delimiter = DEFAULT_DELIMITER, &block)
      return if nodes.empty?
      block ||= method(:visit)
      head, *tail = nodes
      block.call(head)
      tail.each do |node|
        write(delimiter)
        block.call(node)
      end
    end

    # Return children of node
    #
    # @return [Array<Parser::AST::Node>]
    #
    # @api private
    #
    def children
      node.children
    end

    # Write newline
    #
    # @return [undefined]
    #
    # @api private
    #
    def nl
      emit_eol_comments
      buffer.nl
    end

    # Write comments that appeared before source_part in the source
    #
    # @param [Symbol] source_part
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit_comments_before(source_part = :expression)
      comments_before = comments.take_before(node, source_part)
      return if comments_before.empty?
      emit_comments(comments_before)
      buffer.nl
    end

    # Write end-of-line comments
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit_eol_comments
      comments.take_eol_comments.each do |comment|
        write(WS, comment.text)
      end
    end

    # Write end-of-file comments
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit_eof_comments
      emit_eol_comments
      comments_left = comments.take_all
      return if comments_left.empty?
      buffer.nl
      emit_comments(comments_left)
    end

    # Write each comment to a separate line
    #
    # @param [Array] comments
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit_comments(comments)
      max = comments.size - 1
      comments.each_with_index do |comment, index|
        if comment.type.equal?(:document)
          buffer.append_without_prefix(comment.text.chomp)
        else
          write(comment.text)
        end
        buffer.nl if index < max
      end
    end

    # Write strings into buffer
    #
    # @return [undefined]
    #
    # @api private
    #
    def write(*strings)
      strings.each do |string|
        buffer.append(string)
      end
    end

    # Write end keyword
    #
    # @return [undefined]
    #
    # @api private
    #
    def k_end
      buffer.indent
      emit_comments_before(:end)
      buffer.unindent
      write(K_END)
    end

    # Return first child
    #
    # @return [Parser::AST::Node]
    #   if present
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def first_child
      children.first
    end

    # Write whitespace
    #
    # @return [undefined]
    #
    # @api private
    #
    def ws
      write(WS)
    end

    # Call emit contents of block indented
    #
    # @return [undefined]
    #
    # @api private
    #
    # False positive:
    #
    # rubocop:disable MethodCallWithoutArgsParentheses
    #
    def indented
      buffer = buffer()
      buffer.indent
      nl
      yield
      nl
      buffer.unindent
    end

    # Emit non nil body
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit_body(body = body())
      unless body
        buffer.indent
        nl
        buffer.unindent
        return
      end
      visit_indented(body)
    end

    # Visit indented node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit_indented(node)
      if NOINDENT.include?(node.type)
        visit_plain(node)
      else
        indented { visit_plain(node) }
      end
    end

    # Return parent type
    #
    # @return [Symbol]
    #   if parent is present
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def parent_type
      parent.node_type
    end

    # Delegate to emitter
    #
    # @param [Class:Emitter] emitter
    #
    # @return [undefined]
    #
    # @api private
    #
    def run(emitter, node = node())
      emitter.new(node, self).write_to_buffer
    end

  end # Emitter
end # Unparser
