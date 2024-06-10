unparser
========

![CI](https://github.com/mbj/unparser/workflows/CI/badge.svg)
[![Gem Version](https://img.shields.io/gem/v/unparser.svg)](https://rubygems.org/gems/unparser)

Generate equivalent source for ASTs from [parser](https://github.com/whitequark/parser).

The following constraints apply:

* No support for macruby extensions
* Only support for the [modern AST](https://github.com/whitequark/parser/#usage) format
* Only support for Ruby >= 3.1

Notable Users:

* [mutant](https://github.com/mbj/mutant) - Code review engine via mutation testing.
* [ruby-next](https://github.com/ruby-next/ruby-next) - Ruby Syntax Backports.
* Many other [reverse-dependencies](https://rubygems.org/gems/unparser/reverse_dependencies).

(if you want your tool to be mentioned here please PR the addition with a TLDR of your use case).

Public API:
-----------

While unparser is in the `0.x` versions its public API can change any moment.
I recommend to use `~> 0.x.y` style version constraints that should give the best mileage.

Usage
-----

```ruby
require 'parser/current'
require 'unparser'

ast = Unparser.parse('your(ruby(code))')

Unparser.unparse(ast) # => 'your(ruby(code))'
```

To preserve the comments from the source:

```ruby
require 'parser/current'
require 'unparser'

ast, comments = Unparser.parse_with_comments('your(ruby(code)) # with comments')

Unparser.unparse(ast, comments) # => 'your(ruby(code)) # with comments'
```

Passing in manually constructed AST:
```ruby
require 'parser/current'
require 'unparser'

module YourHelper
  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end
end

include YourHelper

node = s(:def,
  :foo,
  s(:args,
    s(:arg, :x)
  ),
  s(:send,
    s(:lvar, :x),
    :+,
    s(:int, 3)
  )
)

Unparser.unparse(node) # => "def foo(x)\n  x + 3\nend"
```

Note: DO NOT attempt to pass in nodes generated via `AST::Sexp#s`, these ones return
API incompatible `AST::Node` instances, unparser needs `Parser::AST::Node` instances.

Equivalent vs identical:

```ruby
require 'unparser'

node = Unparser.parse(<<~'RUBY')
  %w[foo bar]
RUBY

generated = Unparser.unparse(node) # ["foo", "bar"], NOT %w[foo bar] !

code == generated                 # false, not identical code
Unparser.parse(generated) == node # true, but identical AST
```

Summary: unparser does not reproduce your source! It produces equivalent source.

Ruby Versions:
--------------

Unparsers primay reason for existance is mutant and its
supported [Ruby-Versions](https://github.com/mbj/mutant#ruby-versions).

Basically: All non EOL MRI releases.

If you need to generate Ruby Syntax outside of this band feel free to contact me (email in gemspec).

Testing:
--------

Unparser currently successfully round trips almost all ruby code around. Using Ruby >= 2.6.
If there is a non round trippable example that is NOT subjected to known [Limitations](#limitations).
please report a bug.

On CI unparser is currently tested against rubyspec with minor [excludes](https://github.com/mbj/unparser/blob/master/spec/integrations.yml).

Limitations:
------------

Source parsed with magic encoding headers other than UTF-8 and that have literal strings.
where parts can be represented in UTF-8 will fail to get reproduced.

A fix is possible as with latest updates the parser gem carries the information.

Example:

Original-Source:
```ruby
# -*- encoding: binary -*-

"\x98\x76\xAB\xCD\x45\x32\xEF\x01\x01\x23\x45\x67\x89\xAB\xCD\xEF"
```

Original-AST:
```
(str "\x98v\xAB\xCDE2\xEF\x01\x01#Eg\x89\xAB\xCD\xEF")
```

Generated-Source:

```ruby
"\x98v\xAB\xCDE2\xEF\x01\x01#Eg\x89\xAB\xCD\xEF"
```

Generated-AST:

```
(str "\x98v\xAB\xCDE2\xEF\u0001\u0001#Eg\x89\xAB\xCD\xEF")
```

Diff:

```
@@ -1,2 +1,2 @@
-(str "\x98v\xAB\xCDE2\xEF\x01\x01#Eg\x89\xAB\xCD\xEF")
+(str "\x98v\xAB\xCDE2\xEF\u0001\u0001#Eg\x89\xAB\xCD\xEF")
```

Installation
------------

Install the gem `unparser` via your prefered method.

People
------

Various people contributed to this repository. See [Contributors](https://github.com/mbj/unparser/graphs/contributors).

Included Libraries
------------------

For dependency reduction reasons unparser ships vendored (and reduced) versions of:

* [abstract_type](https://github.com/mbj/concord) -> Unparser::AbstractType
* [adamantium](https://github.com/dkubb/adamantium) -> Unparser::Adamantium
* [anima](https://github.com/mbj/concord) -> Unparser::Anima
* [concord](https://github.com/mbj/concord) -> Unparser::Concord
* [memoizable](https://github.com/dkubb/memoizable) -> Unparser::Adamantium
* [mprelude](https://github.com/dkubb/memoizable) -> Unparser::Either

Contributing
-------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with version
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Known Users
-------------

* [RailsRocket](https://www.railsrocket.app) - A no-code app builder that creates Rails apps

License
-------

See LICENSE file.
