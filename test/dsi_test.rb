# some tests for the dsi library

# TODO: write tests for: dsibooks, fetch_latest_strip_date,
#        dialog.empty, dialog.read_dialog_raw,
#        dialog.merge_into_dialog, dsi:entry, date.parse,
#        string.sqlquote

require "test/unit"
$: << File.dirname(__FILE__) + "/../lib"
require 'dsi'

class TestDSI < Test::Unit::TestCase

  # test that the DSI.bookpage is working properly by supplying dates
  # and comparing the resulting book names and page numbers to the
  # correct values.
  def test_bookpage_errors
    {
      "1989-04-15" => RuntimeError,    # out of range
      "1000-25-99" => ArgumentError,   # invalid date
      "1991-03-31" => RuntimeError     # uncollected
    }.each do |date,exception|
      assert_raise exception do
        DSI.bookpage(Date.parse_json(date))
      end
    end
  end


  # get the book and page for a date, and compare against provided values
  def test_bookpage
    [
     [ "1989-04-16", "morons",     4],
     [ "1989-04-17", "morons",     6],
     [ "1989-04-18", "morons",     6],
     [ "1989-04-19", "morons",     6],
     [ "1989-04-20", "morons",     7],
     [ "1989-04-21", "morons",     7],
     [ "1989-04-22", "morons",     7],
     [ "1989-04-23", "morons",     8],
     [ "1989-10-16", "morons",   110],
     [ "1989-10-22", "shave",      6],
     [ "1989-10-23", "shave",      7],
     [ "1989-10-24", "shave",      7],
     [ "1989-10-25", "shave",      7],
     [ "1989-10-26", "shave",      8],
     [ "1989-10-29", "shave",      9],
     [ "1990-01-28", "shave",      48],
     [ "1990-03-02", "shave",      62],
     [ "1990-04-29", "shave",      87],
     [ "1990-11-09", "willy",      48],
     [ "1991-08-19", "wits",       49],
     [ "1992-02-23", "wits",      129],
     [ "1992-03-04", "wits",      133],
     [ "1992-06-20", "wits",      179],
     [ "1992-12-14", "pumped",      7],
     [ "1992-12-15", "pumped",      7],
     [ "1992-12-16", "pumped",      7],
     [ "1992-12-17", "pumped",      8],
     [ "1992-12-18", "pumped",      8],
     [ "1992-12-19", "pumped",      8],
     [ "1992-12-20", "pumped",      9],
     [ "1993-01-07", "pumped",     17],
     [ "1993-05-23", "pumped",     75],
     [ "1993-09-27", "pumped",    127],
#     [ "1993-09-28", "fugitive",   11], # TODO: is this right?
     [ "1993-12-23", "fugitive",   48],
     [ "1994-03-26", "fugitive",   87],
     [ "1994-03-27", "fugitive",   88],
     [ "1994-06-16", "fugitive",  123],
     [ "1996-02-12", "anti",       43],
     [ "1997-03-15", "journey",    92],
     [ "1997-08-13", "journey",   158],
     [ "1998-06-23", "step",       77],
     [ "1998-09-07", "step",      110],
     [ "1998-12-15", "acts",       33],
     [ "2000-02-06", "wag",        92],
     [ "2000-09-17", "ignorance",  68],
     [ "2001-01-30", "ignorance", 126],
     [ "2001-05-02", "paradise",   45],
     [ "2001-07-16", "paradise",   78],
     [ "2002-06-23", "body",      104],
     [ "2002-10-09", "words",      30],
     [ "2004-12-06", "thriving",    9],
     [ "2004-12-15", "thriving",   12],
     [ "2005-08-12", "thriving",  115],
     [ "2006-04-12", "rebooting",  99],
     [ "2008-10-04", "freedom",   123],
     [ "2008-12-08", "loyal",      31],
     [ "2009-01-27", "loyal",      52],
     [ "2009-03-25", "loyal",      76],
     [ "2009-06-26", "loyal",     116],
     [ "2010-01-30", "tempted",    87],
    ].each do |rec|
      cbook, cpage = DSI.bookpage(Date.parse_json(rec[0]))
      assert_equal(rec[1], cbook)
      assert_equal(rec[2], cpage)
    end
  end


  # test the book id to book name conversion
  def test_bookname
    {
      'morons' => "Always Postpone Meetings with Time-Wasting Morons",
      "pretend" => "This is the Part Where You Pretend to Add Value"
    }.each do |bookid,bookname|
      assert_equal(bookname, DSI.bookname(bookid))
    end
  end


  # unknown book id
  def test_bookname_problem
    assert_raise(RuntimeError) do
      DSI.bookname("no such book id")
    end
  end


  # check DSI.dsistrips caches its result
  def test_multiple_dsi
    assert_same(DSI.dsistrips, DSI.dsistrips)
  end


  # check DSI.dsistriphash caches its result
  def test_multiple_dsihash
    assert_same(DSI.dsistriphash, DSI.dsistriphash)
  end
end
