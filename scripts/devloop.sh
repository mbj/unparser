while inotifywait **/*.rb Gemfile unparser.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order default \
    && bundle exec ./mutant.sh --since master -- 'Unparser*' \
    && bundle exec rubocop
done
