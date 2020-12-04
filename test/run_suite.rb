#!/usr/bin/ruby
# frozen_string_literal: true

# looks for all tests in test/*_test.rb and runs them
# this file supports the Makefile, and is not used with the rake command

# require files in test dir
$LOAD_PATH.unshift(__dir__)

# get all the tests
Dir.glob('test/*_test.rb').each do |file|
  require File.basename(file.delete_suffix('.rb'))
end

# end
