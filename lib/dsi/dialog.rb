# work with the dsi dialog data

class DSI::Dialog

  # read and parse the dsidialog json file then return an object
  # containing the contents.  cache it so we only parse it once
  def self.dsidialog(file = DSI::DATADIR + "dsidialog.json")
    cache = DialogCache.instance().dialog
    cache[file] = JSON.parse(File.readlines(file).join) unless
      cache.has_key?(file)
    cache[file]
  end


  # provide an empty dialog structure to merge to
  def self.empty
    blank = <<JSON
{
  "dsidialog": {
    "header": { "description" : "this file was generated: #{Date.today.to_s}" },
    "dialog": [ ]
  }
}
JSON

    JSON.parse(blank)
  end


  # reformat the array returned by dsidialog into a hash indexed by a
  # date object.  cache the result
  def self.dsidialoghash(file = DSI::DATADIR + "dsidialog.json")
    hashcache = DialogCache.instance().dialoghash
    unless hashcache.has_key?(file)
      hashcache[file] = Hash.new
      populate_dialoghash(file, hashcache)
    end
    hashcache[file]
  end


  # open and read a dialog file that has been downloaded and put into
  # a local file
  def self.read_dialog_raw(file)
    cache = DialogCache.instance().dialog
    unless cache.has_key?(file)
      newdialog = Hash.new
      cache[file] = dialog_raw(IO.readlines(file), newdialog)
    end
    cache[file]
  end


  # merge one dialog array into another. both args are as returned by
  # DSI.dsidialog
  # args:
  #   dialog    - the array to be added to
  #   newdialog - the array to be added from
  def self.merge_into_dialog(dialog, newdialog)
    # turn the main dialog array into a hash, making checking for dates easier
    dialoghash = hashdialog(dialog)
    dd = dialog["dsidialog"]["dialog"]
    newdialog.keys.each do |date|
      dd << self.dialognew(date, newdialog[date]) unless
        dialoghash.has_key?(date)
    end
    dd.sort! { |aa,bb| aa['date'].to_s <=> bb['date'].to_s }
  end


  private


  def self.dialognew(date, dialog)
    res = Hash.new
    res["date"] = date

    # make sure lines is an array
    if dialog.class == Array
      res["lines"] = dialog
    else
      res["lines"] = [ dialog ]
    end
    res
  end


  def self.hashdialog(dialog)
    dialoghash = Hash.new
    dialog['dsidialog']['dialog'].each do |str|
      next if str == {}
      dialoghash[str['date']] = str
    end
    dialoghash
  end


  def self.dialog_raw(lines, ret)
    is_sanand = lines[0] =~ /id\s+quote/
    lines.reject! { |line| line =~ /^(id\s+quote|pg|sh)/ }
    lines.each do |dline|
      is_sanand ? process_sanand_line(dline, ret) :
        process_john_line(dline, ret)
    end
    ret
  end


  def self.populate_dialoghash(file, hashcache)
    dsidialog(file)['dsidialog']['dialog'].each do |str|
      hashcache[file][Date.parse_json(str['date'])] = str
    end
  end


  def self.process_john_line(dln, ret)
    ( ddate, dlines ) = parse_john_line(dln)
    return if ddate == nil
    add_john_line(ddate, dlines, ret)
  end


  def self.process_sanand_line(dline, ret)
    ( sdt, lines ) = dline.split(/\t/)
    ret[Date.parse_yyyymmdd(sdt)] = lines[0, lines.length - 4]
  end


  def self.add_john_line(ddate, dlines, itm)
    dt = Date.parse_yymmdd(ddate)
    nonutf = strip_non_utf(dlines)
    if itm.has_key?(dt)
      itm[dt] += " " + nonutf
    else
      itm[dt] = nonutf
    end
  end


  def self.parse_john_line(dln)
    return nil if /^pg/.match(dln) or /^sh/.match(dln) or /^\.\.\./.match(dln)
    items = /(\d+) [*-][*-]+ ?(.*)/.match(dln) or return nil
    dlines = items[2]
    return nil if dlines =~ /^\s+$/ or dlines == ""
    [ items[1], dlines ]
  end


  # the "john" file contains non ascii characters.  get rid of them.
  # TODO: find a better way
  def self.strip_non_utf(string)
    string.
      sub(/It's 108..? by the window/, "It's 108 degrees by the window").
      sub(/"M..?tley Cr..?e"/, '"Motley Crue"').
      sub(/Erwin Schr..?dinger/, 'Erwin Schrodinger').
      sub(/M..?bius strip/, 'Mobius strip').
      sub(/insists i..?on using/, 'insists on using').
      sub(/32..? Fahrenheit/, '32 degrees Fahrenheit')
  end
end


require 'singleton'
class DialogCache  # :nodoc: all
  include Singleton
  attr_accessor :dialog , :dialoghash
  def initialize
    @dialog = Hash.new
    @dialoghash = Hash.new
  end
end
