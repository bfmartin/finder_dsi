# -*- ruby -*-
#
# part of finder_dsi

require 'net/http'
require 'rake/clean'
require 'rake/notes/rake_task'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems'
require 'rubygems/package_task'

# files and dirs used in this file
data_dir     = 'data'
download_dir = 'download'
dialog_json  = data_dir + '/dsidialog.json'
raw_john     = download_dir + '/dialog-john.txt'
gen_bin      = 'bin/dsi-generate-dialog.rb'

# default task.
task default: [:test]

# define the gem
gemspec = Gem::Specification.new do |s|
  s.name        = 'finder_dsi'
  s.summary     = 'Dilbert Strip Index'
  s.version     = '4.0.0'
  s.authors     = ['bfmartin']
  s.date        = '2012-08-01'
  s.description = <<TEXT
Data and programs used by the Dilbert Strip Finder
at http://www.bfmartin.ca/finder/
TEXT
  s.email       = 'http://www.bfmartin.ca/contact'
  s.files       = Dir['lib/finderdsi.rb', 'lib/finderdsi/*.rb', 'bin/*.rb',
                      "#{data_dir}/dsistrips.json",
                      "#{data_dir}/dsibooks.json",
                      'README.md', 'TODO.md', 'Changelog']
  s.homepage    = 'http://www.bfmartin.ca/'
end

# create a zip file
Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_zip = true
end

# add these dirs / files when cleaning
CLEAN.include(download_dir, 'pkg', 'html')
CLOBBER.include(dialog_json)

# run unit tests
Rake::TestTask.new do |t|
  t.test_files = FileList['test/*.rb']

  if !File.exist?(dialog_json) && (ARGV.include?('test') || ARGV.empty?)
    # default to all tests except if the dialog has not been prepared
    t.test_files = FileList['test/*.rb'].exclude('test/dialog_test.rb')
    # print a warning message about the missing dialog, but only if we
    # are running a test
    puts <<TEXT

NOTE: Skipping tests for dialog. run 'rake dialog:prepare' first

TEXT
  end
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include('lib/*.rb', 'lib/finderdsi/*.rb', 'test/*.rb')
  rdoc.options << '--all' # uncomment to get private methods as well
end

# work with the dialog data
namespace :dialog do
  directory download_dir

  file raw_john => [download_dir] do
    url = 'http://john.ccac.rwth-aachen.de:8000/ftp/dilbert/dilbert.txt'
    data = dialog_fetch(url)
    File.open(raw_john, 'w') { |fil| fil.syswrite(data) }
  end

  file dialog_json => [raw_john] do |f|
    ruby %{ #{gen_bin} #{f.prerequisites.join(' ')} > #{f.name} }
  end

  # wrap up the task with a nice name
  desc 'prepare dialog.json by downloading raw and reformatting'
  task prepare: dialog_json

  def dialog_fetch(url)
    myurl = URI.parse(url)
    req = Net::HTTP::Get.new(myurl.path)
    res = Net::HTTP.start(myurl.host, myurl.port) { |http| http.request(req) }
    res.body
  end
end
