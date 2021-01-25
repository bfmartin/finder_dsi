# frozen_string_literal: true

# extend system classes with useful methods

require 'finderdsi/stem'
require 'date'

# add stem method and sql quoting to strings
class String
  include Stemmable

  # break a string into words, stem each word and combine back into a string,
  # then collapse multiple spaces characters into a single space
  def stemmed
    return self if self == '\N' || self == 'NULL' # don't stem this

    split(/[\s.?!,-]/).collect(&:stem).join('  ').gsub(/\s+/, ' ')
    # split(/[\s\.\?\!,-]/).collect do |word|
    # word.stem
    # end.join('  ').gsub(/\s+/, ' ')
  end

  # prepare a string for inserting into SQL.  add surrounding single
  # quotes and turn internal quotes into two quotes unless the string
  # is NULL
  def sqlquote
    return self if self == 'NULL' # dont quote this

    "'#{gsub(/'/, "''")}'"
  end
end

# add extra string parsing
class Date
  # return a date object for YYMMDD
  def self.parse_yymmdd(ymd)
    year = ymd[0, 2].to_i
    year += 100 if year < 30
    year += 1900
    Date.civil(year, ymd[2, 2].to_i, ymd[4, 2].to_i)
  end

  # return a date object for YYYYMMDD
  def self.parse_yyyymmdd(ymd)
    Date.civil(ymd[0, 4].to_i, ymd[4, 2].to_i, ymd[6, 2].to_i)
  end

  # return a date object for YYYY-MM-DD.  this is typical in some
  # json.  Date.parse also does it, but this one is *much* faster
  def self.parse_json(stringdate)
    Date.civil(stringdate[0, 4].to_i, stringdate[5, 2].to_i,
               stringdate[8, 2].to_i)
  end
end
