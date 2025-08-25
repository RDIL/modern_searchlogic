#!/bin/bash

set -e

export POSTGRES_URL="postgres://postgres:password@localhost:5432/postgres"
export RAILS_ENV="test"
export PROJECT_ROOT="$(git rev-parse --show-toplevel)"

convert_appraisal_to_gemfile() {
    local appraisal_name="$1"
    echo "${appraisal_name//-/_}"
}

if [ -z "$APPRAISAL_NAME" ]; then
    echo "Error: APPRAISAL_NAME environment variable is required"
    echo "Usage: APPRAISAL_NAME=rails-3 ./script/run_specs.sh"
    exit 1
fi

if [ -z "$TEST_APP_DIR" ]; then
    echo "Error: TEST_APP_DIR environment variable is required"
    echo "Usage: TEST_APP_DIR=spec/app_rails3 ./script/run_specs.sh"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/$TEST_APP_DIR" ]; then
    echo "Error: Test app directory '$TEST_APP_DIR' does not exist"
    exit 1
fi

GEMFILE_NAME=$(convert_appraisal_to_gemfile "$APPRAISAL_NAME")

echo "Running specs for $APPRAISAL_NAME in $TEST_APP_DIR"
echo "Using gemfile: $GEMFILE_NAME.gemfile"

cd "$PROJECT_ROOT" || exit 1

echo "Setting up database for $APPRAISAL_NAME..."
cd "$TEST_APP_DIR" || exit 1

BUNDLE_GEMFILE="$PROJECT_ROOT/gemfiles/${GEMFILE_NAME}.gemfile" bundler exec rake db:create:all
BUNDLE_GEMFILE="$PROJECT_ROOT/gemfiles/${GEMFILE_NAME}.gemfile" bundler exec rake db:environment:set RAILS_ENV=test
BUNDLE_GEMFILE="$PROJECT_ROOT/gemfiles/${GEMFILE_NAME}.gemfile" bundler exec rake db:migrate

echo "Running specs for $APPRAISAL_NAME..."
echo "Finding spec files..."

cd "$PROJECT_ROOT" || exit 1
SPEC_FILES=$(find . -name "*_spec.rb" -not -path "./spec/app_rails*/*" -exec realpath {} \; | tr '\n' ' ')

if [ -z "$SPEC_FILES" ]; then
    echo "No spec files found"
    exit 1
fi

echo "Found spec files: $SPEC_FILES"

export RUBYLIB="$PROJECT_ROOT/spec:$RUBYLIB"

cd "$TEST_APP_DIR" || exit 1

export RAILS_ROOT="$PROJECT_ROOT/$TEST_APP_DIR"

BUNDLE_GEMFILE="$PROJECT_ROOT/gemfiles/${GEMFILE_NAME}.gemfile" bundle exec ruby -r "$PROJECT_ROOT/spec/ruby3_compatibility" -e "require 'rspec/core'; RSpec::Core::Runner.run(ARGV)" $SPEC_FILES

echo "Specs completed for $APPRAISAL_NAME"
