module Unparser
  # All unparser constants maybe included in other libraries.
  module Constants

    # Return frozen symbol set from enumerable
    #
    # @param [Enumerable]
    #
    # @return [Set<Symbol>]
    #
    # @api private
    #
    def self.symbol_set(enumerable)
      enumerable.map(&:to_sym).freeze
    end
    private_class_method :symbol_set

    # All unary operators of the ruby language
    UNARY_OPERATORS = symbol_set %w(
      ! ~ -@ +@
    )

    # All binary operators of the ruby language
    BINARY_OPERATORS = symbol_set %w(
      + - * / & | && || << >> ==
      === != <= < <=> > >= =~ !~ ^
      ** %
    )

    OPERATOR_PRECEDENCE = IceNine.deep_freeze([
      # if/unless/while/until modifiers
      %i[and or],
      %i[not],
      %i[defined?],
      # assignment
      # rescue modifier
      # ternary operator
      # range creation
      %i[||],
      %i[&&],
      %i[== === != =~ !~ <=>],
      %i[< <= >= >],
      %i[| ^],
      %i[&],
      %i[<< >>],
      %i[+ -],
      %i[* / %],
      %i[-@],
      %i[**],
      %i[! ~ +@]
    ].each_with_index.flat_map { |types, weight| types.map { |t| [ t, weight ] } }.to_h)

    # The following table attempts to summarize what a hypothetical "average"
    # Ruby programmer understands about operator precedence
    # If our "average" programmer doesn't have any idea what the precedence
    # of a certain operator is, it shouldn't appear in this table
    INTUITIVE_PRECEDENCE = IceNine.deep_freeze([
      %i[and or not defined?],
      %i[|| && == === != =~ !~ <=>],
      %i[< <= >= > << >>],
      %i[+ -],
      %i[* / %],
      %i[-@ ! ~ +@]
    ].each_with_index.flat_map { |types, weight| types.map { |t| [ t, weight ] } }.to_h)

    # The "average" Ruby programmer will probably not be very sure about
    # operators which have the *same* precedence in the above table.
    # For example, they know that * binds tighter than +, but might not be
    # sure about * and %
    # But there are some which *everybody* understands...
    INTUITIVE_PRECEDENCE_EQUAL = [:+, :-].freeze

    OPERATOR_ASSOCIATIVITY = IceNine.deep_freeze({
      left: %i[and or || && == === != =~ !~ <=> < <= >= > | ^ & << >> + - * / %],
      right: %i[not -@ ** ! ~ +@]
    }.flat_map { |side, ops| ops.map { |op| [op, side] } }.to_h)

    COMMENT = '#'

    WS       = ' '
    NL       = "\n"
    T_DOT    = '.'
    T_LT     = '<'
    T_DLT    = '<<'
    T_AMP    = '&'
    T_ASN    = '='
    T_SPLAT  = '*'
    T_DSPLAT = '**'
    T_ASR    = '=>'
    T_PIPE   = '|'
    T_DCL    = '::'
    T_NEG    = '!'
    T_OR     = '||'
    T_AND    = '&&'
    T_COLON  = ':'

    M_PO  = '('
    M_PC  = ')'

    SNGL_QUOTE = "'"
    DBL_QUOTE  = '"'

    # Keywords
    K_DO       = 'do'
    K_DEF      = 'def'
    K_END      = 'end'
    K_BEGIN    = 'begin'
    K_CASE     = 'case'
    K_CLASS    = 'class'
    K_SELF     = 'self'
    K_ENSURE   = 'ensure'
    K_DEFINE   = 'define'
    K_MODULE   = 'module'
    K_RESCUE   = 'rescue'
    K_RETURN   = 'return'
    K_UNDEF    = 'undef'
    K_DEFINED  = 'defined?'
    K_PREEXE   = 'BEGIN'
    K_POSTEXE  = 'END'
    K_SUPER    = 'super'
    K_BREAK    = 'break'
    K_RETRY    = 'retry'
    K_REDO     = 'redo'
    K_NEXT     = 'next'
    K_FALSE    = 'false'
    K_TRUE     = 'true'
    K_IF       = 'if'
    K_AND      = 'and'
    K_ALIAS    = 'alias'
    K_ELSE     = 'else'
    K_ELSIF    = 'elsif'
    K_FOR      = 'for'
    K_NIL      = 'nil'
    K_NOT      = 'not'
    K_IN       = 'in'
    K_OR       = 'or'
    K_UNLESS   = 'unless'
    K_WHEN     = 'when'
    K_WHILE    = 'while'
    K_UNTIL    = 'until'
    K_YIELD    = 'yield'
    K_ENCODING = '__ENCODING__'
    K_EEND     = '__END__'
    K_FILE     = '__FILE__'
    K_THEN     = 'then'

    DEFAULT_DELIMITER = ', '.freeze

    CURLY_BRACKETS = IceNine.deep_freeze(%w({ }))

    KEYWORDS = constants.each_with_object([]) do |name, keywords|
      value = const_get(name).freeze
      next unless name.to_s.start_with?('K_')
      keywords << value.to_sym
    end.to_set.freeze

  end # Constants
end # Unparser
