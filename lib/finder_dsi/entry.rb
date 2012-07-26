# this class helps turn hashes read from the dsistrips json file, and
# potentially the dsidialog json file into values suitable for
# inserting into / updating a database
#
# create the instance using the hash from dsistrips, dsidialog, and a string
# containing the string the database expects for a null value.
#
# then call the getters to retrieve properly formatted data strings

class Finder_DSI::Entry
  # hash containing strip arg, as read from the json
  attr_accessor :strip
  # hash containing the dialog, as read from the json
  attr_accessor :dialog
  # what to use for null value during insert/update/load statement
  attr_accessor :null

  # null = string to use for null value
  # - SQL insert or update statements use NULL
  # - SQL loader programs use \\\N
  def initialize(strip, dialog=nil, null='\N')
    @strip = strip
    @dialog = dialog
    @null = null
  end


  # strip date as string in the form YYYY-MM-DD
  def date
    @strip["date"]
  end


  # string containing the synopsis. add the note, if available
  def synopsis_note
    note = @strip['note']
    syn = @strip["synopsis"]
    if note != nil
      syn + " " + note
    else
      syn
    end
  end


  # a string containing comma separated character names, if available
  def characters
    chars = @strip["characters"]
    if chars != nil
      chars.join(",")
    else
      @null
    end
  end


  # string containing comma-separated keywords and subject, if available
  def keywords_subject
    key = @strip['keywords']
    if key != nil
      [ @strip['subject'], key ].join(',')
    else
      @null
    end
  end


  # string containing lines of dialog if available
  def dialog
    if @dialog != nil
      @dialog["lines"].join(" ")
    else
      @null
    end
  end


  # string containing the full book name, if available
  def bookname
    bookpage(date) if @bookname == nil
    @bookname
  end


  # string containing the book id, if available
  def bookid
    bookpage(date) if @bookid == nil
    @bookid
  end


  # string containing the page number, if available
  def page
    bookpage(date) if @page == nil
    @page
  end


  private


  # look up the book and page for a date
  def bookpage(stripdate)
    begin
      @bookid, @page = Finder_DSI.bookpage(Date.parse_json(stripdate))
      @bookname = Finder_DSI.bookname(@bookid)
    rescue
      @bookname = @bookid = @page = @null
    end
  end
end
