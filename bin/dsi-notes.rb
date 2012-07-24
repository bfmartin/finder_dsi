#!/usr/bin/ruby
#
# reads the dsistrips json file and print all items with notes.
# Useful for browsing and debugging.

$: << File.dirname(__FILE__) + "/../lib"
require 'dsi'

DSI.dsistrips['dsistrips']['strip'].each do |s|
  puts s['date'] + "  " + s['note'] if s['note'] != nil
end
