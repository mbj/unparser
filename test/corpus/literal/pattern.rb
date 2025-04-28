case foo
in A[1, 2, *a, 3] then
  true
in [1, 2, ] then
  y
in A(x:) then
  true
in {**a} then
  true
in {} if true then
  true
in [x, y, *] then
  true
in {a: 1, aa: 2} then
  true
in {} then
  true
in {**nil} then
  true
in 1 | 2 then
  true
in 1 => a then
  true
in ^x then
  true
in 1
in 2 then
  true
else
  true
end
case foo
in A[1, 2, *a, 3]
end
case foo
in A
else
end
1 in [a]
1 => [a]
1 => [*]
1 in [*, 42, *]
1 in [*, a, *foo]
a => %i[a b]
a => %w[a b]
a => ["a", "b"]
a => [:a, :b]
a => [:a, "b"]
a => [true, false, nil]
a => {a: 1, b: 2}
a in %i[a b]
a in %w[a b]
a in ["a", "b"]
a in [:a, :b]
a in [:a, "b"]
a in [true, false, nil]
a in {a: 1, b: 2}
case foo
in %i[a b]
end
case foo
in %w[a b]
end
case foo
in [:a, "b"]
end
case foo
in [1, 2]
end
case foo
in [true, false, nil]
end
a => %I[a b #{foo(1)}]
a => %W[a b #{foo(1)}]
case a
in %I[#{1 + 1}]
end
case foo
in %i[a b c $FILE]
end
