#!/usr/bin/ruby
#
# when a new book comes out, this generates update statements to
# update the database to reflect the new bookname, bookid and page
# numbers
#
# generates update statements to add book and page numbers for
# existing strips.

$: << File.dirname(__FILE__) + "/../lib"
require 'finder_dsi'


def self.gen_sql_book(bookid)
  found = nil
  Finder_DSI.dsibooks['dsibooks']['book'].each do |bk|
    if bk['id'] == bookid
      gen_sql_book_bk(bk)
      found = 1
    end
  end
  puts "-- no book id matches #{ bookid }" unless found
end


def self.gen_sql_book_bk(bk)
  bk['page_list']['page'].each do |range|
    gen_sql_range(bk['id'], bk['title'], range)
  end
end


# relies heavily on String.sqlquote defined in finder_dsi/ext.rb
def self.gen_sql_range(id, title, range)
  (Date.parse_json(range['start_date']) ..
   Date.parse_json(range['end_date'])).each do |date|
    bookid, page = Finder_DSI.bookpage(date)
    puts <<SQL
update dsi set bookid=#{ id.sqlquote },bookname=#{ title.sqlquote },page=#{ page.to_s.sqlquote } where date=#{ date.to_s.sqlquote };
SQL
  end
end


def self.show_usage_message
  ids = Finder_DSI.dsibooks['dsibooks']['book'].collect { |bk| bk['id'] }
  puts <<TEXT
usage: #{ $0 } <id> [<id>]

where <id> is from #{ ids.join(", ") }
TEXT
end


# program begin
if ARGV.size == 0
  self.show_usage_message
else
  ARGV.each do |bookid|
    self.gen_sql_book(bookid)
  end
end
# program end
