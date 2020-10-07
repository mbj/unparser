#/usr/bin/bash -ex

bundle exec mutant                                    \
  --zombie                                            \
  --ignore-subject 'Unparser::CLI*'                   \
  --ignore-subject 'Unparser::Validation.from_string' \
  $*
