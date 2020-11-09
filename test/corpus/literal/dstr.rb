if true
  <<~HEREDOC
    #{}a
  HEREDOC
end
if true
  <<~HEREDOC
    a
    #{}a
    b
  HEREDOC
  x
end
<<~HEREDOC
  \#{}\#{}
  #{}
  #{}
  #{}
HEREDOC
<<-HEREDOC rescue nil
#{}
a
HEREDOC
"a#$1"
"a#$a"
"a#@a"
"a#@@a"
