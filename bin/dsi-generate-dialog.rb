#!/usr/bin/ruby
#
# this will read raw dialog files (as downloaded from different web
# locations) and merge them into a standard format JSON file.
#
# specify one or more raw dialog files on the command line. the order
# is important -- if multiple files contain dialog for the same date,
# the first one specified will 'win'
#
# The JSON is printed to STDOUT

$LOAD_PATH << __dir__ + '/../lib'
require 'finder_dsi'

# execution starts here
dialog = FinderDSI::Dialog.empty

ARGV.each do |arg|
  dialog_in = FinderDSI::Dialog.read_dialog_raw(arg)
  FinderDSI::Dialog.merge_into_dialog(dialog, dialog_in)
end

puts JSON.pretty_generate(dialog)
