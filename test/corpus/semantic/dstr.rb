<<DOC
DOC

<<'DOC'
DOC

<<~DOC
DOC

<<~'DOC'
DOC

<<DOC
  a
DOC

<<'DOC'
  a
DOC

<<DOC
  a
  #{}
DOC

<<~DOC
  a
  #{}
DOC

<<~DOC
  a
  #{}
  b
DOC

<<~DOC
  a
    b
DOC

<<'DOC'
a

b
DOC

<<'DOC'
 a

 b
DOC

<<'DOC'
 a\nb
DOC

<<DOC
#{}a
 #{}a
DOC

<<DOC
  #{}
  \#{}
DOC

<<DOC
 a#{}b
 c
DOC

<<~DOC
  #{}
DOC

if true
  <<~DOC
    #{}
  DOC
end

if true
  <<~DOC
    b#{}
  DOC
end

if true
  <<~DOC
    #{}a
  DOC
end

if true
  <<-'DOC'
   a

   b
  DOC
end

"#{}a"

%(\n"#{}"\n)

%Q(-\n"#{}"\n)

"a
#{}
b"

"a\n#{}
b"

"a
#{}\nb"

'a' \
"#{}"

"" "" ""

"a#{@a}" "b"
"a#@a" "b"
"a#$a" "b"
"a#@@a" "b"

# Issue #412: Multiline dynamic strings without trailing newline
"\n\n #{x}"
"\n#{x}"
"#{x}\n"
"foo\n#{x}"

# Issue #415: Performance with repeated interpolations
"foo: #{a}\n\nfoo: #{a}\n\n"
"foo: #{a}\n\nfoo: #{a}\n\nfoo: #{a}\n\n"
"foo: #{a}\n\nfoo: #{a}\n\nfoo: #{a}\n\nfoo: #{a}\n\n"
"foo: #{a}\n\nfoo: #{a}\n\nfoo: #{a}\n\nfoo: #{a}\n\nfoo: #{a}\n\n"
