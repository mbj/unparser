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
