#!/usr/bin/ruby
#
# reads dsistrips for dates past the latest date already loaded and
# creates lines to be inserted into the bfmartin.ca database.  See the
# database schema in the README.  also loads dialog if available,
# otherwise inserts nulls.
#
# if no options are supplied on the command line, it looks up the
# latest date from the website.  optionally, a date may be supplied
# with the --since command line option.  only strips after this date
# are loaded.

require 'optparse'
$: << File.dirname(__FILE__) + "/../lib"
require 'finder_dsi'


# read the latest strips file and return those after the specified date
def self.add_strips_after_date(strips, date)
  strips = Finder_DSI.dsistrips['dsistrips']['strip'].select do |strip|
    sdate = strip["date"]
    strips[sdate] = strip if sdate.to_s > date
  end
end


# add strips from tab-delimited files specified on the command line
def self.add_quick_strips(strips, latest_date, file)
  File.readlines(file).each do |line|
    ( date, synop ) = line.chomp.split("\t")
    dt = Date.parse_yymmdd(date).to_s
    strips[dt] = Hash['date' => dt, 'synopsis' => synop ] if
      dt > latest_date and !strips.has_key?(dt) and synop != nil
  end
end


##########################################################################

# start

latest_date = nil

OptionParser.new do |opts|
  opts.banner = "Usage: incremental.rb [--since YYYY-MM-DD] [file...]"
  opts.on("-h", '--help', "Show help") do |v|
    puts opts
    exit
  end
  opts.on("-s", '--since DATE', 'Only output strips since DATE') do |val|
    latest_date = val
  end
end.parse!

latest_date = Finder_DSI.fetch_latest_strip_date if latest_date == nil

strips = Hash.new
dialog = Finder_DSI::Dialog.dsidialoghash

self.add_strips_after_date(strips, latest_date)
ARGV.each do |file|
  self.add_quick_strips(strips, latest_date, file)
end

strips.each do |date,strip|
  fmt = Finder_DSI::Entry.new(strip, dialog[Date.parse_json(date)], 'NULL')

  puts <<SQL unless fmt.date == nil or fmt.synopsis_note == ""
insert into dsi (pubdate, title, dialog, title_stem, dialog_stem) values ('#{ fmt.date }', #{ fmt.synopsis_note.sqlquote }, #{ fmt.dialog.sqlquote }, #{ fmt.synopsis_note.stemmed.sqlquote }, #{ fmt.dialog.stemmed.sqlquote });
SQL
end
