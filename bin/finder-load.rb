#!/usr/bin/ruby
#
# reads dsistrips and creates lines to be loaded into the bfmartin.ca
# database.  See the database schema in the README.  also loads dialog
# if available, otherwise inserts nulls.
#
# use a statement like this in maria db / mysql. this assumes an empty table.
#    > load data local infile 'loadtable.txt' into table dsi;

$: << File.dirname(__FILE__) + "/../lib"
require 'finder_dsi'

dialog = Finder_DSI::Dialog.dsidialoghash

Finder_DSI.dsistrips['dsistrips']['strip'].each do |strip|
  fmt = Finder_DSI::Entry.new(strip, dialog[Date.parse_json(strip['date'])])

  puts [ '\N', fmt.date, fmt.synopsis_note, fmt.characters,
         fmt.keywords_subject, fmt.dialog, fmt.bookid, fmt.bookname,
         fmt.page, fmt.synopsis_note.stemmed,
         fmt.keywords_subject.stemmed, fmt.dialog.stemmed ].join("\t")
end
