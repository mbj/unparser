unparser
========

[![Build Status](https://secure.travis-ci.org/mbj/unparser.png?branch=master)](http://travis-ci.org/mbj/unparser)
[![Dependency Status](https://gemnasium.com/mbj/unparser.png)](https://gemnasium.com/mbj/unparser)
[![Code Climate](https://codeclimate.com/github/mbj/unparser.png)](https://codeclimate.com/github/mbj/unparser)

Generate equivalent inputs for ASTs from whitequarks awesome [parser](https://github.com/whitequark/parser).

Usage
-----

```
require 'unparser'
Unparser.unparse(your_ast) # => "the code"
```

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
