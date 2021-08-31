# frozen_string_literal: true

# parent class
class FinderDSI
  # this class helps turn hashes read from the dsistrips json file, and
  # potentially the dsidialog json file into values suitable for
  # inserting into / updating a database
  #
  # create the instance using the hash from dsistrips, dsidialog, and a string
  # containing the string the database expects for a null value.
  #
  # then call the getters to retrieve properly formatted data strings
  class Entry
    # hash containing strip arg, as read from the json
    attr_accessor :strip
    # hash containing the dialog, as read from the json
    # attr_accessor :dialogv
    # what to use for null value during insert/update/load statement
    attr_accessor :null

    # null = string to use for null value
    # - SQL insert or update statements use NULL
    # - SQL loader programs use \\\N
    def initialize(strip, dialog = nil, null = '\N')
      @strip = strip
      @dialogv = dialog
      @null = null
    end

    # strip date as string in the form YYYY-MM-DD
    def date
      @strip['date']
    end

    # string containing the synopsis. add the note, if available
    def synopsis_note
      note = @strip['note']
      syn = @strip['synopsis']
      if note.nil?
        syn
      else
        "#{syn} #{note}"
      end
    end

    # a string containing comma separated character names, if available
    def characters
      chars = @strip['characters']
      if chars.nil?
        @null
      else
        chars.join(',')
      end
    end

    # string containing comma-separated keywords and subject, if available
    def keywords_subject
      key = @strip['keywords']
      if key.nil?
        @null
      else
        [@strip['subject'], key].join(',')
      end
    end

    # string containing lines of dialog if available
    def dialog
      if @dialogv.nil?
        @null
      else
        @dialogv['lines'].join(' ')
      end
    end
  end
end
