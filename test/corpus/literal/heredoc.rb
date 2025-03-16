<<-HEREDOC.foo(//, nil)
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
line_9
HEREDOC
<<-HEREDOC && bar
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
{ bar => 1, foo => <<-HEREDOC }
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
foo(bar: <<-HEREDOC)
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
[<<-HEREDOC]
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
foo(<<-HEREDOC) {
    a

    b
      f
    e

    d
    f
HEREDOC
}
foo = <<-HEREDOC
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
foo(<<-HEREDOC)
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
<<-HEREDOC
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
"segment_1" "segment_2" "segment_3" "segment_4"
foo[<<-HEREDOC]
line_1
line_2
line_3
line_4
line_5
line_6
line_7
line_8
HEREDOC
<<-HEREDOC
a b
  a
  "$! }:\#{}"
  #{}
HEREDOC
