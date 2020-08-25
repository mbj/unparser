# v0.4.8 unreleased

* Handle `nil` as input correctly returning the empty string [#151](https://github.com/mbj/unparser/pull/151)
* Change to specific node type when unparser fails on an unknown node type: [#150](https://github.com/mbj/unparser/pull/150)
* Significantly improve verifier (only useful for debugging)
* Add `Unparser::Color` module for colorized source diffs

# v0.4.7 2020-01-03

* Add support for endless ranges
* Change to allow parser 2.7, even while syntax is not yet supported.
  This reduces downstream complexity.

# v0.4.6 2020-01-02

* Upgrades to allow parser dependency to ~> 2.6.5

# v0.4.5 2019-05-10

* Bump parser dependency to ~> 2.6.3

# v0.4.4 2019-03-27

* Bump parser dependency to ~> 2.6.2

# v0.4.3 2019-02-24

* Bump parser dependency to ~> 2.6.0

# v0.4.2 2018-12-04

* Drop hard ruby version requirement. Still officially I'll only support 2.5.

# v0.4.1 2018-12-03

* Fix unparsing of `def foo(bar: bar())`

# v0.4.0 2018-12-03

* Change to modern AST format.
* Add experimental `Unparser.{parser,parse,parse_with_comments}`

# v0.3.0 2018-11-16

* Drop support for Ruby < 2.5

# v0.2.7 2018-07-18

* Add emitters for `__FILE__` and `__LINE__`
  https://github.com/mbj/unparser/pull/70

# v0.2.7 2018-02-09

* Allow ruby_parser 2.5

# v0.2.6 2017-05-30

* Reduce memory consumption via not requirering all possible parsers
* Allow ruby 2.4
* Update parser dependency

# v0.2.5 2016-01-24

* Add support for ruby 2.3
* Bump parser dependency to ~>2.3.0
* Trade uglier for more correct dstring / dsyms
* Drop support for ruby < 2.1

# v0.2.4 2015-05-30

* Relax parser dependency to ~>2.2.2

# v0.2.3 2015-04-28

* Compatibility with parser ~>2.2.2, >2.2.2.2

# v0.2.2 2015-01-14

* Really add back unofficial support for 1.9.3

# v0.2.1 2015-01-14

* Add back unofficial support for 1.9.3

# v0.2.0 2015-01-12

* Bump required ruby version to 2.0.0

# v0.1.17 2015-01-10

* Fix jruby complex / rational generation edge case
* Support generation under MRI 2.2

# v0.1.16 2014-11-07

* Add emitter for complex and rational literals
* Fix edge cases for MLHS
* Fix differencies from 2.2.pre7 series of parser

# v0.1.15 2014-09-24

* Handle syntax edge case for MRI 2.1.3 parser.

# v0.1.14 2014-06-15

* Fix emitter to correctly unparse foo[] = 1

# v0.1.13 2014-06-08

* Add support for rubinius.

# v0.1.12 2014-04-13

* Add support for 2.1 kwsplat

# v0.1.11 2014-04-11

* Fix performance on local variable scope inspection

# v0.1.10 2014-04-06

* Fix emit of inline rescues in combination with control flow keywords.
* Begin corpus testing on rake ci against rubyspec

# v0.1.9 2014-01-14

* Fix emit of proc { |(a)| }

# v0.1.8 2014-01-11

* Fix all bugs found while round tripping rubyspec.

# v0.1.7 2014-01-03

* Add back support for root nodes of type resbody https://github.com/mbj/unparser/issues/24

# v0.1.6 2013-12-31

* Emit 1.9 style hashes where possible: https://github.com/mbj/unparser/pull/23
* Fix invalid quoting of hash keys: https://github.com/mbj/unparser/issues/22
* Fix crash on take before introduced by code refactorings: https://github.com/mbj/unparser/issues/20
* Fix crash on comment reproduction https://github.com/mbj/unparser/issues/17

# v0.1.5 2013-11-01

* Fix crash with comment reproduction.

# v0.1.4 2013-11-01

* Code cleanups.
* Remove warnings.

# v0.0.3 2013-06-17

* Adjust to changes in parser 2.0.0.beta5 => beta6

# v0.0.2 2013-06-17

Crappy release

# v0.0.1 2013-06-15

Initial release
