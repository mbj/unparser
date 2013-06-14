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

    K_DO      = 'do'.freeze
    K_DEF     = 'def'.freeze
    K_END     = 'end'.freeze
    K_BEGIN   = 'begin'.freeze
    K_CASE    = 'case'.freeze
    K_CLASS   = 'class'.freeze
    K_MODULE  = 'module'.freeze
    K_RESCUE  = 'rescue'.freeze
    K_RETURN  = 'return'.freeze
    K_UNDEF   = 'undef'.freeze
    K_DEFINED = 'defined?'.freeze
    K_PREEXE  = 'BEGIN'.freeze
    K_POSTEXE = 'END'.freeze
    K_SUPER   = 'super'.freeze
    K_BREAK   = 'break'.freeze
    K_RETRY   = 'retry'.freeze
    K_REDO    = 'redo'.freeze
    K_NEXT    = 'next'.freeze
    K_IF      = 'if'.freeze
    K_ALIAS   = 'alias'.freeze
    K_ELSE    = 'else'.freeze
    K_FOR     = 'for'.freeze
    K_NIL     = 'nil'.freeze
    K_IN      = 'in'.freeze
    K_UNLESS  = 'unless'.freeze
    K_WHEN    = 'when'.freeze
    K_WHILE   = 'while'.freeze
    K_UNTIL   = 'until'.freeze
    K_YIELD   = 'yield'.freeze

    KEYWORDS = constants.map do |name|
      if name.to_s.start_with?('K_')
        const_get(name)
      end
    end.compact.freeze

  end # Constants
end # Unparser
