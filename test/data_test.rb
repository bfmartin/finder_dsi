require 'test/unit'
$LOAD_PATH << __dir__ + '/../lib'
require 'finder_dsi'

# some tests for data validations.
class TestValidateDSIData < Test::Unit::TestCase
  # examine the data retrieved from the json file and make sure it is
  # in the proper format.
  def test_read_dsistrips
    json = nil
    assert_nothing_raised(RuntimeError) { json = FinderDSI.dsistrips }

    dsistrips = json['dsistrips']
    assert(dsistrips['strip'].size > 6000)
    check_dsistrips_keys(json, dsistrips)
  end

  # some tests to validate each strip has the proper data.
  # several tests are bundled so as only have to loop through the strips once.
  def test_each_strip
    dates_seen = {}
    FinderDSI.dsistrips['dsistrips']['strip'].each do |strip|
      each_strip_run(strip, dates_seen)
    end
  end

  # make sure the version numbers from the different places are consistent
  def test_version
    chl = FinderDSI.version_from_changelog
    assert_equal(chl, FinderDSI.dsistrips['dsistrips']['header']['version'])
  end

  # check for gaps in the date range
  def test_date_gap
    dates = FinderDSI.dsistrips['dsistrips']['strip']
                     .collect { |strip| Date.parse_json(strip['date']) }.sort
    expect = (FinderDSI::FIRST_STRIP_DATE..dates.last).sort
    assert_equal(expect.size, dates.size)
    assert_equal(expect, dates)
  end

  # test the re-defined dsistrip data structure
  def test_dsihash
    strips = FinderDSI.dsistriphash
    assert_instance_of(Hash, strips)
    # same number of entries as the json structure
    assert_equal(strips.size, FinderDSI.dsistrips['dsistrips']['strip'].size)
    # check for a date or two
    assert(strips.key?(FinderDSI::FIRST_STRIP_DATE))
  end

  private

  # support method for test_each_strip
  def each_strip_run(strip, dates_seen)
    each_strip_dates(strip, dates_seen)
    strip_has_json_fields(strip)
    strip_has_sentence_ending(strip)
    strip_has_proper_spaces(strip)
  end

  # support method for test_space_characters
  def strip_has_proper_spaces(strip)
    [strip['synopsis'], strip['note']].each do |str|
      assert_no_match(/\s\s/, str,
                      "extra space chars for #{strip['date']} in #{str}")
    end
  end

  # support method for test_sentence_ending
  def strip_has_sentence_ending(strip)
    [strip['synopsis'], strip['note']].each do |str|
      next if str.nil?
      tstr = str.sub(/"$/, '') # remove trailing quote, if any
      assert_match(/[\.\?\!]$/, tstr,
                   "Non-sentence end \"#{str}\" from #{strip['date']}")
    end
  end

  def each_strip_dates(strip, dates_seen)
    assert(strip.key?('date'), 'strip has no date: ' + strip.to_s)
    strip_has_valid_date(strip)
    strip_is_not_duplicate_date(strip, dates_seen)
  end

  # a bit redundant, since duplicate dates show up in other tests.
  # but this test pinpoints which date
  def strip_is_not_duplicate_date(strip, seen)
    stripdate = strip['date']
    flunk "duplicate date #{stripdate}" if seen.key?(stripdate)
    seen[stripdate] = 1
  end

  # helper method for test_each_strip
  def strip_has_json_fields(strip)
    # mandatory field
    check_field(strip, 'synopsis', String)

    # optionals
    [['characters', Array], ['keywords', Array], ['subject', String],
     ['note', String], ['saga', String],
     ['comment', String]].each do |key, klass|
      check_field(strip, key, klass) if strip.key?(key)
    end
    check_field_date(strip)
  end

  # perform a few checks for the date field
  def check_field_date(strip)
    # should only be date remaining
    stripkeys = strip.keys
    stripdate = strip['date']
    assert_equal(1, stripkeys.size,
                 "#{stripdate} has extra key(s): #{stripkeys.join(',')}")
    assert_equal(String, stripdate.class)
  end

  # a support method for has_json_field.
  def check_field(strip, key, klass)
    stripdate = strip['date']
    assert(strip.key?(key), "strip #{stripdate} does not have #{key}")
    assert_instance_of(klass, strip[key],
                       "#{key} not #{klass} in #{stripdate}")
    strip.delete(key)
  end

  # helper method for test_each_strip
  def strip_has_valid_date(strip)
    stripdate = strip['date']
    stripdate_obj = Date.parse_json(stripdate)
    assert_not_nil(stripdate_obj, 'strip date not valid: ' + stripdate)

    # date must be between 1989-04-16 and today
    assert(stripdate_obj >= FinderDSI::FIRST_STRIP_DATE,
           'date in the past: ' + stripdate)
    assert(stripdate_obj <= Date.today, 'date in the future: ' + stripdate)
  end

  def check_dsistrips_keys(json, dsistrips)
    dsikeys = dsistrips.keys
    assert_equal(2, dsikeys.size, 'dsi has wrong keys: ' + dsikeys.join(','))
    jkeys = json.keys
    assert_equal(1, jkeys.size, 'top has extra key(s): ' + jkeys.join(','))
  end
end
