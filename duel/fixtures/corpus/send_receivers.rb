module A
  foo ||= ((a, _) = b)
end

module A
  local = 1
  local.bar
end
class A
end.bar
module A
end.bar
begin
rescue
end.bar
case (def foo
end; :bar)
when bar
end.baz
case foo
when bar
end.baz
class << self
end.bar
def self.foo
end.bar
def foo
end.bar
until foo
end.bar
while foo
end.bar
loop {
}.bar
if foo
end.baz
(/bar/ =~ :foo).foo
(1..2).max
(foo =~ /bar/).foo
/bar/ =~ :foo
