retry
case foo
in {"#{"a"}": 1} then
  true
end
/\c*a/
/\c*a\c*/
/\c*\c*\c*/
(break foo) || a
(return foo) || a
a = b || break
a = b || next
a || (break foo)
b or break
b or next
break or b
next or b
return or a
for foo[] in m do
end
for (a, b) in bar do
  baz
end
