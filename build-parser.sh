#!/usr/bin/bash

set -euf -o pipefail

cd $(bundle show parser)
sudo apt-get install ragel
bundle install
bundle exec rake generate
cd -
