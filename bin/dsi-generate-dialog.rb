#!/usr/bin/ruby
#
# this will read raw dialog files (as downloaded from different web
# locations) and merge them into a standard format JSON file.
#
# specify one or more raw dialog files on the command line. the order
# is important -- if multiple files contain dialog for the same date,
# the first one specified will 'win'
#
# The JSON is printed to STDOUT by default, or an output file can be
# specified.

require 'optparse'
$: << File.dirname(__FILE__) + "/../lib"
require 'finder_dsi'


# execution starts here
output_file = nil
OptionParser.new do |opts|
  opts.banner = "Usage: generate-dsidialog.rb [-o file] [inputfile...]"
  opts.on("-h", '--help', "Show help") do |v|
    puts opts
    exit
  end
  opts.on("-o", '--output file', 'output to file (default stdout)') do |v|
    output_file = v
  end
end.parse!

dialog = Finder_DSI::Dialog.empty

ARGV.each do |arg|
  dialog_in = Finder_DSI::Dialog.read_dialog_raw(arg)
  Finder_DSI::Dialog.merge_into_dialog(dialog, dialog_in)
end

if output_file == nil
  puts JSON.pretty_generate(dialog)
else
  File.open(output_file, "w") { |fil| fil.puts JSON.pretty_generate(dialog) }
end
