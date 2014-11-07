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
