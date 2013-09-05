unparser
========

[![Build Status](https://secure.travis-ci.org/mbj/unparser.png?branch=master)](http://travis-ci.org/mbj/unparser)
[![Dependency Status](https://gemnasium.com/mbj/unparser.png)](https://gemnasium.com/mbj/unparser)
[![Code Climate](https://codeclimate.com/github/mbj/unparser.png)](https://codeclimate.com/github/mbj/unparser)

Generate equivalent source for ASTs from whitequarks awesome [parser](https://github.com/whitequark/parser).

This library is in early development stage and still has some bugs/missing features.
Nevertheless it is able to regenerate it own source and serves well for
[mutant](https://github.cm/mbj/mutant) mutators and the in-memory vendoring for self hosting mutant.

This library dropped the reproduction of 1.8 syntax in the 0.1.0 release.

Usage
-----

```ruby
require 'unparser'
Unparser.unparse(your_ast) # => "the code"
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

Installation
------------

Install the gem `unparser` via your prefered method.

Credits
-------

* [Markus Schirp (mbj)](https://github.com/mbj) Author

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
