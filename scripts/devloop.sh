while inotifywait lib/**/*.rb test/**/*.rb spec/**/*.rb Gemfile unparser.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order defined \
    && bundle exec ./bin/parser-round-trip-test \
    && bundle exec mutant run --zombie --since HEAD~1 --fail-fast -- 'Unparser*' \
    && bundle exec rubocop
done
