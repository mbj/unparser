# v0.7.0 2024-09-16

[#366](https://github.com/mbj/unparser/pull/366)

* Fix all known dstring issues.
* Interface changes.

# v0.6.15 2024-06-10

[#373](https://github.com/mbj/unparser/pull/373)

* Fix additonal keyword dispatch

# v0.6.14 2024-06-10

[#369](https://github.com/mbj/unparser/pull/369)

* Remove support for ruby-3.0, its EOL.

# v0.6.13 2024-02-01

[#361](https://github.com/mbj/unparser/pull/361)

* Fix unparsing of symbols that do not round trip under `#inspect`

# v0.6.12 2024-01-10

[#355](https://github.com/mbj/unparser/pull/355)

* Fix conditionals with empty bodies.

# v0.6.11 2023-10-31

[#354](https://github.com/mbj/unparser/pull/354)

* Remove support for ruby 2.7

# v0.6.10 2023-10-31

[#351](https://github.com/mbj/unparser/pull/351)

* Fix missing heredocs on op-assign rhs

# v0.6.9 2023-10-08

[#348](https://github.com/mbj/unparser/pull/348)

* Fix crash on kwrestarg hash member

[#349](https://github.com/mbj/unparser/pull/349)

* Fix {begin,end}less {i,e}range flipflops

# v0.6.8 2023-06-14

[#347](https://github.com/mbj/unparser/pull/347)

* Fix binary operator with csend receiver. [Fix #345]

# v0.6.7 2023-01-08

[#338](https://github.com/mbj/unparser/pull/338)

* Add required MFA for rubygems pushes.

# v0.6.6 2023-01-06

[#336](https://github.com/mbj/unparser/pull/336)

* Add support for ruby-3.2 syntax.

# v0.6.5 2022-04-17

[#312](https://github.com/mbj/unparser/pull/312)

* Fix #311, emitting of heredocs within block that has arguments.

[#313](https://github.com/mbj/unparser/pull/313)

* Remove Ruby-2.6 support as its EOL

# v0.6.4 2022-02-12

[#299](https://github.com/mbj/unparser/pull/299)

* Add 3.1+ syntax support.

[#300](https://github.com/mbj/unparser/pull/300)

* Add 3.0+ node support for `find_pattern` and `match_rest`

[#298](https://github.com/mbj/unparser/pull/298)

* Add `parser` gem derived round trip tests.

[#297](https://github.com/mbj/unparser/pull/297)

* Fix emit of of `match_pattern` vs `match_pattern_p`

[#298](https://github.com/mbj/unparser/pull/298)

* Add round trip tests dynamically derived from the `parser` gems test suite to CI

# v0.6.3 2022-01-16

[#290](https://github.com/mbj/unparser/pull/290)

* Depend on parser-3.1.0.
* This is not yet Ruby 3.1 syntax support, only
  supporting the existing feature set on an updated `parser` gem.

# v0.6.2 2021-11-09

[#281](https://github.com/mbj/unparser/pull/268)

* Fix unary operator with argument.

# v0.6.1 2021-11-08

[#279](https://github.com/mbj/unparser/pull/279)

* Fix binary operator with kwargs argument.

[#268](https://github.com/mbj/unparser/pull/268)

* Remove ruby 2.5 support since its EOL.

# v0.6.0 2021-01-06

[#245](https://github.com/mbj/unparser/pull/245)

* Change to raise Unparser::InvalidNode error in some cases when unparsing invalid AST.
* Change `Unparser.unparse` into an official public API.
* Remove lots of dependencies.

# v0.5.7 2020-12-25

* Fix heredocs in return arguments [#244](https://github.com/mbj/unparser/pull/244)

# v0.5.6 2020-12-25

* Add full Ruby 3.0 Syntax support [#233](https://github.com/mbj/unparser/pull/233)

# v0.5.5 2020-12-24

* Fix in-pattern without body [#231](https://github.com/mbj/unparser/pull/231)

# v0.5.4 2020-11-04

* Fix forced ternary on control keyword [#191](https://github.com/mbj/unparser/pull/191)

# v0.5.3 2020-10-18

* Add required ruby version '>= 2.5' to gemspec.

# v0.5.2 2020-10-16

* Fix unary csends to emit correctly.
* Add `Unparser.unparse_validate` interface

# v0.5.1 2020-10-09

* Change to emit empty `dstr` as `%()`

# v0.5.0 2020-10-08

* Add 2.7 syntax support
* Fix lots of edge cases via leveraging parser specs
* Add `--literal` mode for CLI

# v0.4.9 2020-09-10

* Change packaging to avoid git in gemspec.

# v0.4.8 2020-05-25

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
