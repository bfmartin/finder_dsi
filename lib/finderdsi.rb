# frozen_string_literal: true

# this works with both json and json/pure, and the speed difference is
# small.  json/pure seems available more places, though.
# require 'json/pure'
require 'json'
require 'net/http'
require 'date'

# some methods to work with the dsi data
class FinderDSI
  # default location of json files.  must end with a slash
  DATADIR = "#{__dir__}/../data/"

  # date of first dilbert strip
  FIRST_STRIP_DATE = Date.new(1989, 4, 16)

  # read and parse the dsistrips json file then return an object
  # containing the contents.  cache it so we only parse it once
  #
  # this returns an array of dates and is suitable for iterating over
  # all dates.  for a hash by date, see dsistripshash.
  #
  # example usage:
  #   strips = FinderDSI.dsistrips
  #
  # results in:
  #   strips['dsistrips']                >> Hash containing keys 'strip'
  #                                         and 'header'
  #   strips['dsistrips']['strip']       >> Array containing all strips
  #   strips['dsistrips']['strip'].first >> Hash containing keys date,
  #                                         subject, synopsis, note,
  #                                         characters, keywords.
  #                                         Date and synopsis fields are
  #                                         always present, the rest are
  #                                         optional
  #
  # note: all keys and non-nil values, and everything else including
  # the date, are strings.
  def self.dsistrips(file = "#{DATADIR}dsistrips.json")
    cache = FinderDSICache.instance.strips
    cache[file] = JSON.parse(File.readlines(file).join) unless cache.key?(file)
    cache[file]
  end

  # call dsistrips and turn the array into a hash indexed by date.  cache it
  # so it's only parsed once
  #
  # this returns a hash of dates and is suitable for looking up strips
  # by date.  for an array to iterate through, see dsistrips.
  #
  # the resulting hash contains:
  #   key:   date (as a Date object)
  #   value: hash containing json structure with keys date, subject,
  #          note, synopsis, characters, keywords.  All keys and values in
  #          this hash are strings, including the date
  def self.dsistriphash(file = "#{DATADIR}dsistrips.json")
    hashcache = FinderDSICache.instance.striphash
    unless hashcache.key?(file)
      hashcache[file] = {}
      populate_striphash(file, hashcache)
    end
    hashcache[file]
  end

  # look up the latest version number from the changelog
  def self.version_from_changelog(file = 'Changelog')
    /Version\s+([\d.]+)/.match(File.readlines(file).find_all do |line|
                                 /Version/.match(line)
                               end.max)[1]
  end

  def self.populate_striphash(file, hashcache)
    dsistrips(file)['dsistrips']['strip'].each do |str|
      hashcache[file][Date.parse_json(str['date'])] = str
    end
  end
end

require 'singleton'
# this is used to cache data from json files and other data
class FinderDSICache # :nodoc: all
  include Singleton
  attr_accessor :strips, :striphash

  def initialize
    @strips = {}
    @striphash = {}
  end
end

require 'finderdsi/entry'
require 'finderdsi/ext'
require 'finderdsi/dialog'
