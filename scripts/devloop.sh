while inotifywait bin/corpus lib/**/*.rb test/**/*.rb spec/**/*.rb Gemfile unparser.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order defined \
    && bundle exec mutant run --zombie --since main --fail-fast -- 'Unparser*'
done
  # && bundle exec ./bin/parser-round-trip-test \
  # && bundle exec rubocop \
  # && bundle exec ./bin/corpus \
