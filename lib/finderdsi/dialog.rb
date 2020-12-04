# frozen_string_literal: true

# top level class
class FinderDSI
  # work with the dsi dialog data
  class Dialog
    # read and parse the dsidialog json file then return an object
    # containing the contents.  cache it so we only parse it once
    def self.dsidialog(file = FinderDSI::DATADIR + 'dsidialog.json')
      cash = DialogCache.instance.dialog
      cash[file] = JSON.parse(File.readlines(file).join) unless cash.key?(file)
      cash[file]
    end

    # provide an empty dialog structure to merge to
    def self.empty
      { 'dsidialog' => { 'header' => { 'description' =>
                                       'this file was generated: ' +
                                         Date.today.to_s },
                         'dialog' => [] } }
      #      blank = <<JSON
      # {
      #  "dsidialog": {
      #  "header": { "description" : "this file was generated: #{Date.today}" },
      #    "dialog": [ ]
      #  }
      # }
      # JSON
      #      JSON.parse(blank)
    end

    # reformat the array returned by dsidialog into a hash indexed by a
    # date object.  cache the result
    def self.dsidialoghash(file = FinderDSI::DATADIR + 'dsidialog.json')
      hashcache = DialogCache.instance.dialoghash
      unless hashcache.key?(file)
        hashcache[file] = {}
        populate_dialoghash(file, hashcache)
      end
      hashcache[file]
    end

    # open and read a dialog file that has been downloaded and put into
    # a local file
    def self.read_dialog_raw(file)
      cache = DialogCache.instance.dialog
      unless cache.key?(file)
        newdialog = {}
        cache[file] = dialog_raw(IO.readlines(file), newdialog)
      end
      cache[file]
    end

    # merge one dialog array into another. both args are as returned by
    # DSI.dsidialog
    # args:
    #   dialog    - the array to be added to
    #   newdialog - the array to be added from
    def self.merge_into_dialog(dialog, ndia)
      # turn the main dialog array into a hash, making checking for dates easier
      dhash = hashdialog(dialog)
      dd = dialog['dsidialog']['dialog']
      ndia.keys.each { |dt| dd << dianew(dt, ndia[dt]) unless dhash.key?(dt) }
      dd.sort_by { |a| a['date'] }
      # dd.sort { |aa, bb| aa['date'].to_s <=> bb['date'].to_s }
    end

    def self.dianew(date, dialog)
      res = {}
      res['date'] = date

      # make sure lines is an array
      res['lines'] = dialog.class == Array ? dialog : [dialog]
      res
    end

    def self.hashdialog(dialog)
      dialoghash = {}
      dialog['dsidialog']['dialog'].each do |str|
        next if str == {}

        dialoghash[str['date']] = str
      end
      dialoghash
    end

    def self.dialog_raw(lines, ret)
      is_sanand = lines[0] =~ /id\s+quote/
      begin
        lines.reject! { |line| line =~ /^(id\s+quote|pg|sh)/ }
      rescue StandardError
        # do nothing
        _i = 0
      end
      lines.each do |dline|
        is_sanand ? proc_sanand_line(dline, ret) : proc_john_line(dline, ret)
      end
      ret
    end

    def self.populate_dialoghash(file, hashcache)
      dsidialog(file)['dsidialog']['dialog'].each do |str|
        hashcache[file][Date.parse_json(str['date'])] = str
      end
    end

    def self.proc_john_line(dln, ret)
      (ddate, dlines) = parse_john_line(dln)
      return if ddate.nil?

      add_john_line(ddate, dlines, ret)
    end

    def self.proc_sanand_line(dline, ret)
      (sdt, lines) = dline.split(/\t/)
      ret[Date.parse_yyyymmdd(sdt)] = lines[0, lines.length - 4]
    end

    def self.add_john_line(ddate, dlines, itm)
      dt = Date.parse_yymmdd(ddate)
      nonutf = strip_non_utf(dlines)
      itm.key?(dt) ? itm[dt] += ' ' + nonutf : itm[dt] = nonutf
    end

    def self.parse_john_line(dln)
      begin
        return nil if dln =~ /^(pg|sh|\.\.\.)/
      rescue StandardError
        return nil
      end
      return nil unless (items = /(\d+) [*-][*-]+ ?(.*)/.match(dln))

      dlines = items[2]
      return nil if dlines =~ /^\s+$/ || dlines == ''

      [items[1], dlines]
    end

    # the 'john' file contains non ascii characters.  get rid of them.
    def self.strip_non_utf(string)
      string
        .sub(/It's 108..? by the window/, "It's 108 degrees by the window")
        .sub(/"M..?tley Cr..?e"/, '"Motley Crue"')
        .sub(/Erwin Schr..?dinger/, 'Erwin Schrodinger')
        .sub(/M..?bius strip/, 'Mobius strip')
        .sub(/insists i..?on using/, 'insists on using')
        .sub(/32..? Fahrenheit/, '32 degrees Fahrenheit')
    end
  end
end

require 'singleton'
class DialogCache # :nodoc: all
  include Singleton
  attr_accessor :dialog, :dialoghash
  def initialize
    @dialog = {}
    @dialoghash = {}
  end
end
