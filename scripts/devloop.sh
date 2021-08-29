while inotifywait ../mutant/**/*.rb **/*.rb Gemfile unparser.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order default \
    && bundle exec mutant run --zombie --since HEAD~1 --fail-fast -- 'Unparser*' \
    && bundle exec rubocop
done
