#!/usr/bin/ruby
# frozen_string_literal: true

#
# this program will read the dsistrips json file and format it for
# printing.  it takes the keywords or characters or subjects, and
# prints a list of dates that contain that item.
#
# useful for organising/debugging the keywords, and also useful for browsing

require 'optimist'
$LOAD_PATH << __dir__ + '/../lib'
require 'finderdsi'

# extracts the proper items (subject, keywork and/or character) out of
# the strip Hash and returns an array
def self.stripkeys(strip, show)
  arr = []
  [[:subjects,   'subject'],
   [:characters, 'characters'],
   [:keywords,   'keywords']].each do |sym, nam|
    snam = strip[nam]
    skey_add(arr, snam) if show == :all || show == sym
  end
  arr
end

def self.skey_add(arr, snam)
  return if snam.nil?

  item = snam.class == Array ? snam : [snam]
  item.collect!(&:to_s)
  arr.concat(item)
end

# output the list
def self.kout(key)
  key.keys.sort { |aa, bb| aa.casecmp(bb) }.each do |kk|
    puts fmtentry(kk, key[kk])
  end
end

# format an entry for printing.
# the args are entry and an array of dates.  the result is a possibly
# multiline string that lines up the dates in columns
def self.fmtentry(word, dates)
  # 80 columns = entrywidth + (datecount * 11) - 1
  # print the entry in this many columns
  entrywidth = 15
  # print this many dates on a line
  datecount = 6

  spacs = ' '.ljust(entrywidth)
  dates.each_slice(datecount).map { |dateslice| spacs + dateslice.join(' ') }
       .join("\n").sub(spacs, word.ljust(entrywidth)[0, entrywidth])
end

# read the data and organise by entry
def self.readdata(show)
  entryhash = {}
  FinderDSI.dsistrips['dsistrips']['strip'].each do |strip|
    parseentry(entryhash, strip, show)
  end
  entryhash
end

def self.parseentry(entryhash, strip, show)
  stripkeys(strip, show).each do |entry|
    entryhash[entry] = [] unless entryhash.key?(entry)
    entryhash[entry].push(strip['date'])
  end
end

def self.print_by_number(entryhash)
  strips = hash_by_number(entryhash)
  strips.keys.sort.reverse.each do |entry|
    kout(strips[entry])
  end
end

def self.hash_by_number(entryhash)
  strips = {}
  entryhash.keys.each do |key|
    entrykey(entryhash, strips, key)
  end
  strips
end

def self.entrykey(entryhash, strips, key)
  ekey = entryhash[key]
  eksize = ekey.size
  strips[eksize] = {} unless strips.key?(eksize)
  strips[eksize][key] = ekey
end

# execution starts here
show = :keywords
outsort = :alpha

# parse options
options = Optimist.options do
  banner <<~TEXT
    Format the contents if the DSI

    dsi-key.rb [-k|-c|-s|-a] [-n]
  TEXT

  opt :keywords, 'show only keywords (default)'
  opt :characters, 'show only characters'
  opt :subjects, 'show only subjects'
  opt :all, 'show all (keywords, characters and subjects)'
  opt :number, 'sort by top words instead of alpha'
end

# process args from the command line
show = :keywords if options.keywords
show = :characters if options.characters
show = :subjects if options.subjects
show = :all if options.all
outsort = :number if options.number

key = readdata(show)

# print
if outsort == :number
  print_by_number(key)
else
  kout(key)
end
