#/usr/bin/bash -ex

bundle exec mutant                                    \
  --since HEAD~1                                      \
  --zombie                                            \
  --ignore-subject 'Unparser::CLI*'                   \
  --ignore-subject 'Unparser::Validation.from_string' \
  -- 'Unparser*'
