"foo\n" "#{baz}\n" "bar\n"
"#{baz}" "foo\n" "bar\n"
"foo
bar\n"
%()
"a
b
c\n"
"a{foo}n"
"a\n#{foo}
b\n"
if true
  "#{}a"
end
if true
  "a\n#{}a
+b\n"
end
"\#{}\#{}\n#{}\n#{}\n#{}\n"
"#{}
a\n" rescue nil
"a#$1"
"a#$a"
"a#@a"
"a#@@a"
if true
  return "    #{42}\n"
end
foo("  #{bar}\n")
foo("  #{bar}\n") { |x|
}
"\"\"
\n#{}\n"
"<#{}#{}>#{}</#{}>"
<<-HEREDOC
  "#{a},
  a
  #{b}
  b
  #{c}"
HEREDOC
<<-HEREDOC
  a
    b
    \#{}:\#{}
    #{}
  end
  f
HEREDOC
