case foo
in %s[a b]
end
case foo
in %r[foo]
end
case foo
in %r[/foo.+bar/]
end
case foo
in %r:/foo.+bar/:
end
case foo
in %x(rm -rf /)
end
case foo
in %i[]
end
case foo
in %w[]
end
case foo
in %q[a b c #{foo}]
end
case foo
in %q[a b c $FILE]
end
a in b, and c
begin
  foo => e
  e()
end
