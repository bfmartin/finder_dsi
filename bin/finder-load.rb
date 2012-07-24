#!/usr/bin/ruby
#
# reads dsistrips and creates lines to be loaded into the bfmartin.ca
# database.  See the database schema in the README.  also loads dialog
# if available, otherwise inserts nulls.

$: << File.dirname(__FILE__) + "/../lib"
require 'dsi'

dialog = DSI::Dialog.dsidialoghash

DSI.dsistrips['dsistrips']['strip'].each do |strip|
  fmt = DSI::Entry.new(strip, dialog[Date.parse_json(strip['date'])])

  puts [ '\N', fmt.date, fmt.synopsis_note, fmt.characters,
         fmt.keywords_subject, fmt.dialog, fmt.bookid, fmt.bookname,
         fmt.page, fmt.synopsis_note.stemmed,
         fmt.keywords_subject.stemmed, fmt.dialog.stemmed ].join("\t")
end
