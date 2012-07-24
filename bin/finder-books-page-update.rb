#!/usr/bin/ruby
#
# generates html suitable for http://www.bfmartin.ca/dtbooks/

require 'erb'
$: << File.dirname(__FILE__) + "/../lib"
require 'dsi'

template = %q(
<script src="/sites/default/files/sorttable.js" type="text/javascript"></script>

If you want to collect all the strips, these are the books showing the original collections of strips.

<table class="sortable">
<thead>
<tr>
<th>Book</th><th>Title</th><th>From</th><th>To</th>
</tr>
</thead>
<tbody>
% books.each do |b|
<tr>
<td><%= b[:id] %></td><td><span class="booktitle"><%= b[:title] %></span></td><td><span class="stripdate"><%= b[:start].to_s %></span></td><td><span class="stripdate"><%= b[:end].to_s %></span></td>
</tr>
% end
</tbody>
</table>

(You can click on the column headers to sort.)

Most of the strips, but not all, are also published in <span class="booktitle">Dilbert 2.0</span>, a 20-year collection of strips from beginning to <span class="stripdate">2008-04-25</span>.
)

books = DSI.dsibooks['dsibooks']['book'].collect do |bk|
  s = Date.today
  e = Date.new(1989, 1, 1)
  bk['page_list']['page'].each do |r|
    s = Date.parse_json(r['start_date']) if Date.parse_json(r['start_date']) < s
    e = Date.parse_json(r['end_date'])   if Date.parse_json(r['end_date'])   > e
  end
  { :title => bk['title'], :id => bk['id'], :start => s, :end => e }
end

puts ERB.new(template, 0, "%<>").result
