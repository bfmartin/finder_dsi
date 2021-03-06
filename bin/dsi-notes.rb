#!/usr/bin/ruby
# frozen_string_literal: true

#
# reads the dsistrips json file and print all items with notes.
# Useful for browsing and debugging.

$LOAD_PATH << "#{__dir__}/../lib"
require 'finderdsi'

FinderDSI.dsistrips['dsistrips']['strip'].each do |s|
  puts "#{s['date']}  #{s['note']}" unless s['note'].nil?
end
