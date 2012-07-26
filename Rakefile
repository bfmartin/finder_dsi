# -*- ruby -*-
#
# part of finder_dsi

require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'net/http'

# include these dirs / files in the rdoc documentation files
RDOC_DIRS = [ "lib/*.rb", "lib/finder_dsi/*.rb", "test/*.rb" ]

# files and dirs used in this file
data_dir     = "data"
download_dir = "download"
dialog_json  = data_dir + "/dsidialog.json"
raw_john     = download_dir + "/dialog-john.txt"
raw_sanand   = download_dir + "/dialog-sanand.txt"
gen_bin      = "bin/dsi-generate-dialog.rb"


# default task. note: if this is changed, then also change the test task.
task :default => [ :test ]


# define the gem
gemspec = Gem::Specification.new do |s|
  s.name        = 'finder_dsi'
  s.summary     = "Dilbert Strip Index"
  s.version     = '4.0.0'
  s.authors     = [ "bfmartin" ]
  s.date        = '2012-08-01'
  s.description = <<TEXT
Data and programs used by the Dilbert Strip Finder
at http://www.bfmartin.ca/finder/
TEXT
  s.email       = 'http://www.bfmartin.ca/contact'
#  s.executables = [ 'load.rb', 'generate-dsidialog.rb' ]
  s.files       = Dir[ "lib/finder_dsi.rb", "lib/finder_dsi/*.rb", "bin/*.rb",
                       "#{ data_dir }/dsistrips.json",
                       "#{ data_dir }/dsibooks.json",
                       "README.md", "TODO.md", "Changelog" ]
  s.homepage    = 'http://www.bfmartin.ca/'
#  s.test_files = Dir.glob('test/*_test.rb')
end
Rake::GemPackageTask.new(gemspec) do |pkg|; end


# add these dirs / files when cleaning
CLEAN.include( download_dir )
CLOBBER.include( dialog_json )


# run unit tests
Rake::TestTask.new do |t|
  t.test_files = FileList[ "test/*.rb" ]

  if (!File.exist?(dialog_json) and (ARGV.include?("test") or ARGV.empty?))
    # default to all tests except if the dialog has not been prepared
    t.test_files = FileList[ "test/*.rb" ].exclude("test/dialog_test.rb")
    # print a warning message about the missing dialog, but only if we
    # are running a test
    puts <<TEXT

NOTE: Skipping tests for dialog. run 'rake dialog:prepare' first

TEXT
  end
end


# run rdoc
Rake::RDocTask.new do |t|
  t.rdoc_files.include(RDOC_DIRS)
#  t.options << "--all"    # uncomment to get private methods as well
end


# work with the dialog data
namespace :dialog do
  directory download_dir
  require 'zlib'

  file raw_john => [ download_dir ] do
    url = 'http://john.ccac.rwth-aachen.de:8000/ftp/dilbert/dilbert.txt'
    data = dialog_fetch(url)
    File.open(raw_john, "w") { |fil| fil.syswrite(data) }
  end


  file raw_sanand => [ download_dir ] do
    url = 'http://www.s-anand.net/comic.dilbert.jsz'
    data = dialog_fetch(url)
    tempfile = "temp.tmp"
    File.open(tempfile, "w") { |fil| fil.syswrite(data) }
    File.open(tempfile) do |f|
      gz = Zlib::GzipReader.new(f)
      uncomp = gz.read
      File.open(raw_sanand, "w") { |fil| fil.syswrite(uncomp) }
      f.close
    end
    File.delete(tempfile)
  end


  file dialog_json => [ raw_john, raw_sanand ] do |f|
    ruby %( #{ gen_bin } -o #{ f.name } #{ f.prerequisites.join(' ') } )
  end


  # wrap up the task with a nice name
  desc "prepare dialog.json by downloading raw and reformatting"
  task :prepare => dialog_json


  def dialog_fetch(url)
    myurl = URI.parse(url)
    req = Net::HTTP::Get.new(myurl.path)
    res = Net::HTTP.start(myurl.host, myurl.port) { |http| http.request(req) }
    res.body
  end
end
