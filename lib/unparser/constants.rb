module Unparser
  module Constants

    UNARY_OPERATORS = %w(
      !
      ~
      -@
      +@
    ).map(&:to_sym).to_set.freeze


    BINARY_OPERATORS = %w(
      + - * / & | && || << >> ==
      === != <= < <=> > >= =~ !~ ^
      **
    ).map(&:to_sym).to_set.freeze

    WS      = ' '.freeze
    NL      = "\n".freeze
    O_DOT   = '.'.freeze
    O_LT    = '<'.freeze
    O_DLT   = '<<'.freeze
    O_AMP   = '&'.freeze
    O_ASN   = '='.freeze
    O_SPLAT = '*'.freeze
    O_ASR   = '=>'.freeze
    O_PIPE  = '|'.freeze
    O_DCL   = '::'.freeze
    O_NEG   = '!'.freeze
    O_OR    = '||'.freeze
    O_AND   = '&&'.freeze

    M_PO  = '('.freeze
    M_PC  = ')'.freeze

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


    KEYWORDS = constants.map do |name|
      if name.to_s.start_with?('K_')
        const_get(name).freeze.to_sym
      end
    end.compact.freeze

  end # Constants
end # Unparser
