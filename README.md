unparser
========

[![Build Status](https://secure.travis-ci.org/mbj/unparser.png?branch=master)](http://travis-ci.org/mbj/unparser)
[![Dependency Status](https://gemnasium.com/mbj/unparser.png)](https://gemnasium.com/mbj/unparser)
[![Code Climate](https://codeclimate.com/github/mbj/unparser.png)](https://codeclimate.com/github/mbj/unparser)
[![Gem Version](https://img.shields.io/gem/v/unparser.svg)](https://rubygems.org/gems/unparser)

Generate equivalent source for ASTs from whitequarks [parser](https://github.com/whitequark/parser).

This library is able to reproduce 100% of ruby 1.9, 2.0 and 2.1 syntax. Including its own source code.

It serves well for [mutant](https://github.com/mbj/mutant) mutators and the in-memory vendoring for self hosting.

Usage
-----

```ruby
require 'unparser'
Unparser.unparse(your_ast) # => "the code"
```

To preserve the comments from the source:

```ruby
require 'parser/current'
require 'unparser'
ast, comments = Parser::CurrentRuby.parse_with_comments(your_source)
Unparser.unparse(ast, comments) # => "the code # with comments"
```

Equivalent vs identical:

```ruby
require 'unparser'

code = <<-RUBY
%w(foo bar)
RUBY

node = Parser::CurrentRuby.parse(code)

generated = Unparser.unparse(node) # ["foo", "bar"], NOT %w(foo bar) !

code == generated                            # false, not identical code
Parser::CurrentRuby.parse(generated) == node # true, but identical AST
```

Summary: unparser does not reproduce your source! It produces equivalent source.

Testing:
--------

Unparser currently successfully round trips almost all ruby code around. Using MRI-2.0.0.
If there is a non round trippable example that is NOT subjected to known [Limitations](#limitations).
please report a bug.

On CI unparser is currently tested against rubyspec with minor [excludes](https://github.com/mbj/unparser/blob/master/spec/integrations.yml).

Limitations:
------------

Source parsed with magic encoding headers other than UTF-8 and that have literal strings.
where parts can be represented in UTF-8 will fail to get reproduced.

Please note: If you are on 1.9.3 or any 1.9 mode ruby and use UTF-8 encoded source via the magic encoding header:
Unparser does not reproduce these.

A fix might be possible and requires some guessing or parser metadata the raw AST does not carry.

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

* [Markus Schirp (mbj)](https://github.com/mbj) Author
* [Trent Ogren (misfo)](https://github.com/misfo) Adding comment reproduction

Contributing
-------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

See LICENSE file.
