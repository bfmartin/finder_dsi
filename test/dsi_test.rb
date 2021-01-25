# frozen_string_literal: true

require 'test/unit'
$LOAD_PATH << "#{__dir__}/../lib"
require 'finderdsi'

# some tests for the finderdsi library
class TestFinderDSI < Test::Unit::TestCase
  # check FinderDSI.dsistrips caches its result
  def test_multiple_dsi
    assert_same(FinderDSI.dsistrips, FinderDSI.dsistrips)
  end

  # check FinderDSI.dsistriphash caches its result
  def test_multiple_dsihash
    assert_same(FinderDSI.dsistriphash, FinderDSI.dsistriphash)
  end
end
