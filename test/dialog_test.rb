require 'test/unit'
$LOAD_PATH << __dir__ + '/../lib'
require 'finder_dsi'

# some tests for dialog api
# these are split into a separate file so they can be skipped if
# dsidialog.json is not present
class TestDSI < Test::Unit::TestCase
  # make sure the dialog is populated.  confirm that each item has a
  # date and lines of dialog
  def test_dialog
    dialog = FinderDSI::Dialog.dsidialog['dsidialog']['dialog']
    assert(dialog.size > 2700)
    dialog.each do |entry|
      assert_instance_of(Array, entry['lines'])
      assert_instance_of(String, entry['date'])
    end
  end

  # make sure the hash is reasonable
  def test_dialoghash
    dialog = FinderDSI::Dialog.dsidialoghash
    assert_instance_of(Hash, dialog)
    dialogjson = FinderDSI::Dialog.dsidialog

    # same number of entries as the json structure
    assert_equal(dialog.size, dialogjson['dsidialog']['dialog'].size)

    # check for a date or two
    assert(dialog.key?(FinderDSI::FIRST_STRIP_DATE + 1726))
  end

  # check FinderDSI.dsidialog caches its result
  def test_multiple_dsidialog
    assert_same(FinderDSI::Dialog.dsidialog, FinderDSI::Dialog.dsidialog)
  end

  # check FinderDSI.dsidialoghash caches its result
  def test_multiple_dsidialoghash
    assert_same(FinderDSI::Dialog.dsidialoghash,
                FinderDSI::Dialog.dsidialoghash)
  end

  # ensure the dsientry object gets populated correctly
  def test_dsi_entry
    striphash = FinderDSI.dsistriphash
    dialoghash = FinderDSI::Dialog.dsidialoghash
    tdate = FinderDSI::FIRST_STRIP_DATE
    entry = FinderDSI::Entry.new(striphash[tdate], dialoghash[tdate], 'NULL')

    assert_match(/first strip/, entry.synopsis_note)
    assert_equal(FinderDSI::FIRST_STRIP_DATE.to_s, entry.date)
  end
end
