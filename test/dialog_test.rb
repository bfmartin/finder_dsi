# some tests for dialog api
# these are split into a separate file so they can be skipped if
# dsidialog.json is not present

require "test/unit"
require 'dsi'

class TestDSI < Test::Unit::TestCase

  # make sure the dialog is populated.  confirm that each item has a
  # date and lines of dialog
  def test_dialog
    dialog = DSI::Dialog.dsidialog['dsidialog']['dialog']
    assert(dialog.size > 2700)
    dialog.each do |entry|
      assert_instance_of(Array, entry['lines'])
      assert_instance_of(String, entry['date'])
    end
  end


  # make sure the hash is reasonable
  def test_dialoghash
    dialog = DSI::Dialog.dsidialoghash
    assert_instance_of(Hash, dialog)
    dialogjson = DSI::Dialog.dsidialog

    # same number of entries as the json structure
    assert_equal(dialog.size, dialogjson['dsidialog']['dialog'].size)

    # check for a date or two
    assert(dialog.has_key?(DSI::FIRST_STRIP_DATE + 5))
  end


  # check DSI.dsidialog caches its result
  def test_multiple_dsidialog
    assert_same(DSI::Dialog.dsidialog, DSI::Dialog.dsidialog)
  end


  # check DSI.dsidialoghash caches its result
  def test_multiple_dsidialoghash
    assert_same(DSI::Dialog.dsidialoghash, DSI::Dialog.dsidialoghash)
  end


  # ensure the dsientry object gets populated correctly
  def test_dsi_entry
    striphash = DSI.dsistriphash
    dialoghash = DSI::Dialog.dsidialoghash
    tdate = DSI::FIRST_STRIP_DATE
    entry = DSI::Entry.new(striphash[tdate], dialoghash[tdate], 'NULL')

    assert_match(/first strip/, entry.synopsis_note)
    assert_equal(DSI::FIRST_STRIP_DATE.to_s, entry.date)
    assert_match(/lab/, entry.dialog)
    assert_equal('morons', entry.bookid)
    assert_equal(4, entry.page)
  end
end
