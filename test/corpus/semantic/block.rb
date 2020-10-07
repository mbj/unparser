foo do
end

foo do
rescue
end

foo do
  nil rescue nil
  nil
end

foo do |_1|
end

foo(<<-DOC) do |_1|
  b
DOC
  a
end

foo(<<-DOC) do
  b
DOC
  a
end
