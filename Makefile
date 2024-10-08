# Makefile
.PHONY: setup test run lint

setup:
	@echo "Setting up the project..."
	@bundle install

test:
	@echo "Running tests..."
	@bundle exec rspec

run:
	@echo "Running the application..."
	@ruby -r ./lib/easybroker_client.rb -e "EasyBroker::Client.new(ENV['EASYBROKER_API_KEY']).print_property_titles"

lint:
	@echo "Running RuboCop..."
	@bundle exec rubocop

all: setup test lint run