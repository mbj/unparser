foo rescue bar
foo rescue return bar
x = (foo rescue return bar)
foo = [] rescue nil
foo = 1 rescue nil
foo = [1] rescue nil
foo = 1, 2 rescue nil
(foo = []) rescue nil
(foo = 1) rescue nil
(foo = [1]) rescue nil

begin
rescue => A[]
end
