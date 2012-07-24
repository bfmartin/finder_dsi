#!/usr/bin/ruby
#
# this program will read the dsistrips json file and format it for
# printing.  it takes the keywords or characters or subjects, and
# prints a list of dates that contain that item.
#
# useful for organising/debugging the keywords, and also useful for browsing

require 'optparse'
$: << File.dirname(__FILE__) + "/../lib"
require 'dsi'

# extracts the proper items (subject, keywork and/or character) out of
# the strip Hash and returns an array
def self.stripkeys(strip, show)
  arr = Array.new
  [ [ :subjects,   'subject'    ],
    [ :characters, 'characters' ],
    [ :keywords,   'keywords'   ] ].each do |sym, nam|
    snam = strip[nam]
    skey_add(arr, snam) if (show == :all or show == sym)
  end
  arr
end


def self.skey_add(arr, snam)
  if snam != nil
    item = snam.class == Array ? snam : [ snam ]
    item.collect! { |key| key.to_s }
    arr.concat(item)
  end
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

  spacs = " ".ljust(entrywidth)
  dates.each_slice(datecount).map { |dateslice| spacs + dateslice.join(" ") }.
    join("\n").sub(spacs, word.ljust(entrywidth)[ 0, entrywidth ])
end

# read the data and organise by entry
def self.readdata(show)
  entryhash = Hash.new
  DSI.dsistrips['dsistrips']['strip'].each do |strip|
    parseentry(entryhash, strip, show)
  end
  entryhash
end

def self.parseentry(entryhash, strip, show)
  self.stripkeys(strip, show).each do |entry|
    entryhash[entry] = Array.new unless entryhash.has_key?(entry)
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
  strips = Hash.new
  entryhash.keys.each do |key|
    entrykey(entryhash, strips, key)
  end
  strips
end

def self.entrykey(entryhash, strips, key)
  ekey = entryhash[key]
  eksize = ekey.size
  strips[eksize] = Hash.new unless strips.has_key?(eksize)
  strips[eksize][key] = ekey
end

# execution starts here
show = :keywords
outsort = :alpha
OptionParser.new do |opts|
  opts.banner = "Usage: key.rb [-k|-s|-c|-a] [-n]"
  opts.on("-h", '--help', "Show help") do |v|
    puts opts
    exit
  end
  opts.on("-k", '--keywords', 'Show only keywords. (Default)') do |v|
    show = :keywords
  end
  opts.on("-c", '--characters', 'Show only characters') do |v|
    show = :characters
  end
  opts.on("-s", '--subjects', 'Show only subjects') do |v|
    show = :subjects
  end
  opts.on("-a", '--all', 'Show all (keywords, characters and subjects)') do |v|
    show = :all
  end
  opts.on("-n", '--number', 'sort by top words instead of alpha') do |v|
    outsort = :number
  end
end.parse!

key = self.readdata(show)

# print
if outsort == :number
  self.print_by_number(key)
else
  self.kout(key)
end
