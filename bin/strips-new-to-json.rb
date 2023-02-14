#!/usr/bin/ruby
# frozen_string_literal: true

# this is an aid for entering new strip descriptions.
# descriptions are input in a simplified format (two fields per line,
# tab separat4ed)
#
# reads a file in the format (tab separated:
#
#   yymmdd	synopsis
#
# and outputs in json format suitable for adding to dsistrips.json.
# manual merging is required.

require 'json'
# require 'json/pure'
$LOAD_PATH << "#{__dir__}/../lib"
require 'finderdsi'

if ARGV.empty?
  puts <<~TEXT
    converts strip data in the tab-delimited format

    YYMMDD	synopsis

    to JSON suitable to be merged into dsistrips.json
  TEXT
  exit
end

res = []

ARGV.each do |arg|
  File.readlines(arg).each do |l|
    strip = {}
    (d, strip['synopsis']) = l.chomp.split("\t")
    strip['date'] = Date.parse_yymmdd(d).to_s
    res.push(strip) unless strip['synopsis'].nil?
  end
end

a = {}
b = {}
b['strip'] = res.sort_by { |aa| aa['date'] }
# b['strip'] = res.sort { |x, y| x['date'] <=> y['date'] }
a['dsistrips'] = b
puts JSON.pretty_generate(a)
