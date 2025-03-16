begin
rescue
end

begin
rescue
else
end

begin
  a
end

begin
  a
rescue
  b
end

begin
  a
  b
rescue
  b
end

begin
rescue A
else
end

begin; rescue A; else; end

begin
  a
rescue A
  b
rescue B
  c
ensure
  d
end

begin
rescue => self.foo
end

begin
rescue => A.foo
end

begin
rescue => A[i]
end

begin
rescue => A[]
end
