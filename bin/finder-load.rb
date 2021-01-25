#!/usr/bin/ruby
# frozen_string_literal: true

#
# reads dsistrips and creates lines to be loaded into the bfmartin.ca
# database.  See the database schema in the README.  also loads dialog
# if available, otherwise inserts nulls.
#
# use a statement like this in maria db / mysql. this assumes an empty table.
#    > load data local infile 'loadtable.txt' into table dsi;

$LOAD_PATH << "#{__dir__}/../lib"
require 'finderdsi'

dialog = FinderDSI::Dialog.dsidialoghash

FinderDSI.dsistrips['dsistrips']['strip'].each do |strip|
  fmt = FinderDSI::Entry.new(strip, dialog[Date.parse_json(strip['date'])])

  puts ['\N', fmt.date, fmt.synopsis_note, fmt.characters,
        fmt.keywords_subject, fmt.dialog, fmt.synopsis_note.stemmed,
        fmt.keywords_subject.stemmed, fmt.dialog.stemmed].join("\t")
end
