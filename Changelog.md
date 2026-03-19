# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.2] - 2026-02-24

### Added

- Ruby 4.0 specs and CI support ([#423](https://github.com/mbj/unparser/pull/423))

### Changed

- Update to RSpec 4 ([#422](https://github.com/mbj/unparser/pull/422))

### Fixed

- `NoMethodError` when exception backtrace is nil ([#424](https://github.com/mbj/unparser/pull/424))

### Removed

- Ruby 3.1 leftovers ([#420](https://github.com/mbj/unparser/pull/420))

## [0.8.1] - 2025-11-02

### Fixed

- Multiline dynamic strings without trailing newline ([#412](https://github.com/mbj/unparser/pull/412))
- Exponential performance degradation with repeated interpolations ([#415](https://github.com/mbj/unparser/pull/415))

## [0.8.0] - 2025-05-29

### Added

- `prism` parser support for Ruby 3.4 ([#387](https://github.com/mbj/unparser/pull/387), [viralpraxis](https://github.com/viralpraxis))

## [0.7.0] - 2025-03-16

### Changed

- Interface changes ([#366](https://github.com/mbj/unparser/pull/366))

### Fixed

- All known dstring issues ([#366](https://github.com/mbj/unparser/pull/366))

## [0.6.15] - 2024-06-10

### Fixed

- Additional keyword dispatch ([#373](https://github.com/mbj/unparser/pull/373))

## [0.6.14] - 2024-06-10

### Removed

- Support for Ruby 3.0, its EOL ([#369](https://github.com/mbj/unparser/pull/369))

## [0.6.13] - 2024-02-01

### Fixed

- Unparsing of symbols that do not round trip under `#inspect` ([#361](https://github.com/mbj/unparser/pull/361))

## [0.6.12] - 2024-01-10

### Fixed

- Conditionals with empty bodies ([#355](https://github.com/mbj/unparser/pull/355))

## [0.6.11] - 2023-10-31

### Removed

- Support for Ruby 2.7 ([#354](https://github.com/mbj/unparser/pull/354))

## [0.6.10] - 2023-10-31

### Fixed

- Missing heredocs on op-assign rhs ([#351](https://github.com/mbj/unparser/pull/351))

## [0.6.9] - 2023-10-08

### Fixed

- Crash on kwrestarg hash member ([#348](https://github.com/mbj/unparser/pull/348))
- {begin,end}less {i,e}range flipflops ([#349](https://github.com/mbj/unparser/pull/349))

## [0.6.8] - 2023-06-14

### Fixed

- Binary operator with csend receiver ([#347](https://github.com/mbj/unparser/pull/347), [#345](https://github.com/mbj/unparser/issues/345))

## [0.6.7] - 2023-01-08

### Security

- Add required MFA for rubygems pushes ([#338](https://github.com/mbj/unparser/pull/338))

## [0.6.6] - 2023-01-06

### Added

- Support for Ruby 3.2 syntax ([#336](https://github.com/mbj/unparser/pull/336))

## [0.6.5] - 2022-04-17

### Fixed

- Emitting of heredocs within block that has arguments ([#312](https://github.com/mbj/unparser/pull/312), [#311](https://github.com/mbj/unparser/issues/311))

### Removed

- Ruby 2.6 support as its EOL ([#313](https://github.com/mbj/unparser/pull/313))

## [0.6.4] - 2022-02-12

### Added

- 3.1+ syntax support ([#299](https://github.com/mbj/unparser/pull/299))
- 3.0+ node support for `find_pattern` and `match_rest` ([#300](https://github.com/mbj/unparser/pull/300))
- `parser` gem derived round trip tests ([#298](https://github.com/mbj/unparser/pull/298))
- Round trip tests dynamically derived from the `parser` gems test suite to CI ([#298](https://github.com/mbj/unparser/pull/298))

### Fixed

- Emit of `match_pattern` vs `match_pattern_p` ([#297](https://github.com/mbj/unparser/pull/297))

## [0.6.3] - 2022-01-16

### Changed

- Depend on parser-3.1.0. This is not yet Ruby 3.1 syntax support, only supporting the existing feature set on an updated `parser` gem ([#290](https://github.com/mbj/unparser/pull/290))

## [0.6.2] - 2021-11-09

### Fixed

- Unary operator with argument ([#281](https://github.com/mbj/unparser/pull/268))

## [0.6.1] - 2021-11-08

### Fixed

- Binary operator with kwargs argument ([#279](https://github.com/mbj/unparser/pull/279))

### Removed

- Ruby 2.5 support since its EOL ([#268](https://github.com/mbj/unparser/pull/268))

## [0.6.0] - 2021-01-06

### Changed

- Raise `Unparser::InvalidNode` error in some cases when unparsing invalid AST ([#245](https://github.com/mbj/unparser/pull/245))
- `Unparser.unparse` into an official public API ([#245](https://github.com/mbj/unparser/pull/245))

### Removed

- Lots of dependencies ([#245](https://github.com/mbj/unparser/pull/245))

## [0.5.7] - 2020-12-25

### Fixed

- Heredocs in return arguments ([#244](https://github.com/mbj/unparser/pull/244))

## [0.5.6] - 2020-12-25

### Added

- Full Ruby 3.0 syntax support ([#233](https://github.com/mbj/unparser/pull/233))

## [0.5.5] - 2020-12-24

### Fixed

- in-pattern without body ([#231](https://github.com/mbj/unparser/pull/231))

## [0.5.4] - 2020-11-04

### Fixed

- Forced ternary on control keyword ([#191](https://github.com/mbj/unparser/pull/191))

## [0.5.3] - 2020-10-18

### Changed

- Add required ruby version `>= 2.5` to gemspec

## [0.5.2] - 2020-10-16

### Added

- `Unparser.unparse_validate` interface

### Fixed

- Unary csends to emit correctly

## [0.5.1] - 2020-10-09

### Changed

- Emit empty `dstr` as `%()`

## [0.5.0] - 2020-10-08

### Added

- 2.7 syntax support
- `--literal` mode for CLI

### Fixed

- Lots of edge cases via leveraging parser specs

## [0.4.9] - 2020-09-10

### Changed

- Packaging to avoid git in gemspec

## [0.4.8] - 2020-05-25

### Added

- `Unparser::Color` module for colorized source diffs

### Changed

- Specific node type when unparser fails on an unknown node type ([#150](https://github.com/mbj/unparser/pull/150))
- Significantly improve verifier (only useful for debugging)

## [0.4.7] - 2020-01-03

### Added

- Support for endless ranges

### Changed

- Allow parser 2.7, even while syntax is not yet supported. This reduces downstream complexity

## [0.4.6] - 2020-01-02

### Changed

- Allow parser dependency to ~> 2.6.5

## [0.4.5] - 2019-05-10

### Changed

- Bump parser dependency to ~> 2.6.3

## [0.4.4] - 2019-03-27

### Changed

- Bump parser dependency to ~> 2.6.2

## [0.4.3] - 2019-02-24

### Changed

- Bump parser dependency to ~> 2.6.0

## [0.4.2] - 2018-12-04

### Changed

- Drop hard ruby version requirement. Still officially only supporting 2.5

## [0.4.1] - 2018-12-03

### Fixed

- Unparsing of `def foo(bar: bar())`

## [0.4.0] - 2018-12-03

### Added

- Experimental `Unparser.{parser,parse,parse_with_comments}`

### Changed

- Modern AST format

## [0.3.0] - 2018-11-16

### Removed

- Support for Ruby < 2.5

## [0.2.8] - 2018-07-18

### Added

- Emitters for `__FILE__` and `__LINE__` ([#70](https://github.com/mbj/unparser/pull/70))

## [0.2.7] - 2018-02-09

### Changed

- Allow ruby_parser 2.5

## [0.2.6] - 2017-05-30

### Changed

- Reduce memory consumption via not requiring all possible parsers
- Allow Ruby 2.4
- Update parser dependency

## [0.2.5] - 2016-01-24

### Added

- Support for Ruby 2.3

### Changed

- Bump parser dependency to ~> 2.3.0
- Trade uglier for more correct dstring / dsyms

### Removed

- Support for Ruby < 2.1

## [0.2.4] - 2015-05-30

### Changed

- Relax parser dependency to ~> 2.2.2

## [0.2.3] - 2015-04-28

### Changed

- Compatibility with parser ~> 2.2.2, > 2.2.2.2

## [0.2.2] - 2015-01-14

### Added

- Really add back unofficial support for 1.9.3

## [0.2.1] - 2015-01-14

### Added

- Unofficial support for 1.9.3

## [0.2.0] - 2015-01-12

### Changed

- Bump required ruby version to 2.0.0

## [0.1.17] - 2015-01-10

### Added

- Support generation under MRI 2.2

### Fixed

- jruby complex / rational generation edge case

## [0.1.16] - 2014-11-07

### Added

- Emitter for complex and rational literals

### Fixed

- Edge cases for MLHS
- Differences from 2.2.pre7 series of parser

## [0.1.15] - 2014-09-24

### Fixed

- Syntax edge case for MRI 2.1.3 parser

## [0.1.14] - 2014-06-15

### Fixed

- Emitter to correctly unparse `foo[] = 1`

## [0.1.13] - 2014-06-08

### Added

- Support for Rubinius

## [0.1.12] - 2014-04-13

### Added

- Support for 2.1 kwsplat

## [0.1.11] - 2014-04-11

### Fixed

- Performance on local variable scope inspection

## [0.1.10] - 2014-04-06

### Added

- Corpus testing on `rake ci` against rubyspec

### Fixed

- Emit of inline rescues in combination with control flow keywords

## [0.1.9] - 2014-01-14

### Fixed

- Emit of `proc { |(a)| }`

## [0.1.8] - 2014-01-11

### Fixed

- All bugs found while round tripping rubyspec

## [0.1.7] - 2014-01-03

### Added

- Support for root nodes of type resbody ([#24](https://github.com/mbj/unparser/issues/24))

## [0.1.6] - 2013-12-31

### Changed

- Emit 1.9 style hashes where possible ([#23](https://github.com/mbj/unparser/pull/23))

### Fixed

- Invalid quoting of hash keys ([#22](https://github.com/mbj/unparser/issues/22))
- Crash on take before introduced by code refactorings ([#20](https://github.com/mbj/unparser/issues/20))
- Crash on comment reproduction ([#17](https://github.com/mbj/unparser/issues/17))

## [0.1.5] - 2013-11-01

### Fixed

- Crash with comment reproduction

## [0.1.4] - 2013-11-01

### Changed

- Code cleanups
- Remove warnings

## [0.0.3] - 2013-06-17

### Changed

- Adjust to changes in parser 2.0.0.beta5 => beta6

## [0.0.2] - 2013-06-17

Initial (broken) release.

## [0.0.1] - 2013-06-15

Initial release.

[Unreleased]: https://github.com/mbj/unparser/compare/v0.8.2...HEAD
[0.8.2]: https://github.com/mbj/unparser/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/mbj/unparser/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/mbj/unparser/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/mbj/unparser/compare/v0.6.15...v0.7.0
[0.6.15]: https://github.com/mbj/unparser/compare/v0.6.14...v0.6.15
[0.6.14]: https://github.com/mbj/unparser/compare/v0.6.13...v0.6.14
[0.6.13]: https://github.com/mbj/unparser/compare/v0.6.12...v0.6.13
[0.6.12]: https://github.com/mbj/unparser/compare/v0.6.11...v0.6.12
[0.6.11]: https://github.com/mbj/unparser/compare/v0.6.10...v0.6.11
[0.6.10]: https://github.com/mbj/unparser/compare/v0.6.9...v0.6.10
[0.6.9]: https://github.com/mbj/unparser/compare/v0.6.8...v0.6.9
[0.6.8]: https://github.com/mbj/unparser/compare/v0.6.7...v0.6.8
[0.6.7]: https://github.com/mbj/unparser/compare/v0.6.6...v0.6.7
[0.6.6]: https://github.com/mbj/unparser/compare/v0.6.5...v0.6.6
[0.6.5]: https://github.com/mbj/unparser/compare/v0.6.4...v0.6.5
[0.6.4]: https://github.com/mbj/unparser/compare/v0.6.3...v0.6.4
[0.6.3]: https://github.com/mbj/unparser/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/mbj/unparser/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/mbj/unparser/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/mbj/unparser/compare/v0.5.7...v0.6.0
[0.5.7]: https://github.com/mbj/unparser/compare/v0.5.6...v0.5.7
[0.5.6]: https://github.com/mbj/unparser/compare/v0.5.5...v0.5.6
[0.5.5]: https://github.com/mbj/unparser/compare/v0.5.4...v0.5.5
[0.5.4]: https://github.com/mbj/unparser/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/mbj/unparser/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/mbj/unparser/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/mbj/unparser/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/mbj/unparser/compare/v0.4.9...v0.5.0
[0.4.9]: https://github.com/mbj/unparser/compare/v0.4.8...v0.4.9
[0.4.8]: https://github.com/mbj/unparser/compare/v0.4.7...v0.4.8
[0.4.7]: https://github.com/mbj/unparser/compare/v0.4.6...v0.4.7
[0.4.6]: https://github.com/mbj/unparser/compare/v0.4.5...v0.4.6
[0.4.5]: https://github.com/mbj/unparser/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/mbj/unparser/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/mbj/unparser/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/mbj/unparser/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/mbj/unparser/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/mbj/unparser/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/mbj/unparser/compare/v0.2.8...v0.3.0
[0.2.8]: https://github.com/mbj/unparser/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/mbj/unparser/compare/v0.2.6...v0.2.7
[0.2.6]: https://github.com/mbj/unparser/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/mbj/unparser/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/mbj/unparser/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/mbj/unparser/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/mbj/unparser/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/mbj/unparser/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/mbj/unparser/compare/v0.1.17...v0.2.0
[0.1.17]: https://github.com/mbj/unparser/compare/v0.1.16...v0.1.17
[0.1.16]: https://github.com/mbj/unparser/compare/v0.1.15...v0.1.16
[0.1.15]: https://github.com/mbj/unparser/compare/v0.1.14...v0.1.15
[0.1.14]: https://github.com/mbj/unparser/compare/v0.1.13...v0.1.14
[0.1.13]: https://github.com/mbj/unparser/compare/v0.1.12...v0.1.13
[0.1.12]: https://github.com/mbj/unparser/compare/v0.1.11...v0.1.12
[0.1.11]: https://github.com/mbj/unparser/compare/v0.1.10...v0.1.11
[0.1.10]: https://github.com/mbj/unparser/compare/v0.1.9...v0.1.10
[0.1.9]: https://github.com/mbj/unparser/compare/v0.1.8...v0.1.9
[0.1.8]: https://github.com/mbj/unparser/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/mbj/unparser/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/mbj/unparser/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/mbj/unparser/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/mbj/unparser/compare/v0.0.3...v0.1.4
[0.0.3]: https://github.com/mbj/unparser/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/mbj/unparser/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/mbj/unparser/releases/tag/v0.0.1
