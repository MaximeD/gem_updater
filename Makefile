lint:
	bundle exec rubocop

lint_fix:
	bundle exec rubocop -A

tests:
	bundle exec rspec

# Prepare for new release
release:
	./release.rb
