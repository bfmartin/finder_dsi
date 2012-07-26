# some methods to work with the dsi data

# this works with both json and json/pure, and the speed difference is
# small.  json/pure seems available more places, though.
# require 'json/pure'
require 'json'
require 'net/http'
require 'date'


class Finder_DSI

  # default location of json files.  must end with a slash
  DATADIR = File.dirname(__FILE__) + "/../data/"

  # date of first dilbert strip
  FIRST_STRIP_DATE = Date.new(1989, 4, 16)

  # url to find the date of the latest strip in the database (experimental)
  LATEST_DATE_URL = "http://www.bfmartin.ca/lateststrip"


  # convert a date object to an array of book id (e.g. "shave") and
  # page number.  a RuntimeError is raised if the date is out of range
  # (as defined in dsibooks.json).
  #
  # e.g.
  #      bookid, page = Finder_DSI.bookpage(date)
  #
  def self.bookpage(stripdate)
    self.dsibooks['dsibooks']['book'].each do |book|
      bk,pg = check_book(book, stripdate)
      return [ bk, pg ] if bk != nil
    end

    # fail
    raise "date #{ stripdate.to_s } out of range of books"
  end


  # read and parse the dsistrips json file then return an object
  # containing the contents.  cache it so we only parse it once
  #
  # this returns an array of dates and is suitable for iterating over
  # all dates.  for a hash by date, see dsistripshash.
  #
  # example usage:
  #   strips = Finder_DSI.dsistrips
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
  def self.dsistrips(file = DATADIR + "dsistrips.json")
    cache = Finder_DSICache.instance().strips
    cache[file] = JSON.parse(File.readlines(file).join) unless
      cache.has_key?(file)
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
  def self.dsistriphash(file = DATADIR + "dsistrips.json")
    hashcache = Finder_DSICache.instance().striphash
    unless hashcache.has_key?(file)
      hashcache[file] = Hash.new
      populate_striphash(file, hashcache)
    end
    hashcache[file]
  end


  # read and parse the dsibooks json file then return an object
  # containing the contents.  cache it so we only parse it once
  def self.dsibooks(file = DATADIR + "dsibooks.json")
    cache = Finder_DSICache.instance().books
    cache[file] = JSON.parse(File.readlines(file).join) unless
      cache.has_key?(file)
    cache[file]
  end


  # look up the latest version number from the changelog
  def self.version_from_changelog(file = "Changelog")
    /Version\s+([\d.]+)/.match(File.readlines(file).find_all {
                                 |line| /Version/.match(line) }.sort.last)[1]
  end


  # given a book id, return the title.  Uses dsibooks.json
  #
  # an exception is raised if the id is not found
  def self.bookname(id)
    self.dsibooks['dsibooks']['book'].each do |book|
      if book['id'] == id
        return book['title']
      end
    end

    raise "no book with id #{ id } found"
  end


  # fetch the date of the latest strip in the dsi table from the
  # website.  experimental
  def self.fetch_latest_strip_date(url = LATEST_DATE_URL)
#    /latest strip: (\d\d\d\d-\d\d-\d\d)/.
#      match(Net::HTTP.get_response(URI.parse(url)).body)[1]
    '2012-02-29'
  end


  private


  def self.populate_striphash(file, hashcache)
    dsistrips(file)['dsistrips']['strip'].each do |str|
      hashcache[file][Date.parse_json(str['date'])] = str
    end
  end


  def self.check_book(book, stripdate)
    pagelist = book['page_list']
    pagelist['page'].each do |page|
      bk,pg = check_book_range(book, page, stripdate)
      return [ bk, pg ] if bk != nil
    end

    # not found here
    return Array.new(2)
  end


  def self.check_book_range(book, page, stripdate)
    strdt_s = stripdate.to_s
    if strdt_s >= page['start_date'] and strdt_s <= page['end_date']
      return [ book['id'], self.page_number(stripdate, page, book) ]
    end
    return Array.new(2)
  end


  # calculate the page number
  def self.page_number(stripdate, page, book)
    startdate = Date.parse_json(page['start_date'])
    startpage = page['start_page']
    layout = book['page_list']['week_layout'].split(',')

    # adjust the startpage and startdate to begin on a sunday
    startdate, startpage = sunday_start(startdate, startpage, layout)

    startpage + page_offset(stripdate - startdate, layout)
  end


  def self.page_offset(daysdiff, layout, total = 0.to_f)
    pagecount = 0
    layout.each do |lout|
      total += lout.to_f
      return ((daysdiff / 7).to_i * layout.size + pagecount) if
        total > daysdiff % 7
      pagecount += 1
    end
  end


  # adjust date and page number so that it always begins on a sunday.
  # no change if it's already a sunday
  #
  # FIXME: this will probably fail if there are less than the proper
  # number of strips on a page.  for example, if the week_layout says
  # there are 3 strips on a page yet there are only 2.  does this
  # situation exist in the books?  probably, but I'm not sure where.
  def self.sunday_start(date, page, layout)
    total = 0.0
    layout.each do |lout|
      return [ date - total, page ] if total >= date.wday
      page, total = increment_layout(lout.to_f, page, total)
    end
  end


  # perform some math for sunday_start
  def self.increment_layout(lout, page, total)
    total += lout
    page -= 1
    [ page, total ]
  end
end


require 'singleton'
# this is used to cache data from json files and other data
class Finder_DSICache  # :nodoc: all
  include Singleton
  attr_accessor :books, :strips, :striphash
  def initialize
    @books = Hash.new
    @strips = Hash.new
    @striphash = Hash.new
  end
end

require 'finder_dsi/entry'
require 'finder_dsi/ext'
require 'finder_dsi/dialog'
