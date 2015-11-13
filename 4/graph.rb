#!/usr/bin/env ruby
require 'uri'

graph = Hash.new

url=  ''
File.readlines('sewn-crawl-2015.txt').each do |line|
  if m = line.match(/^Visited:\s+(.*)$/)
    url = m.captures[0]
    graph[url] = Array.new
  elsif m = line.match(/^\s+Link:\s+(.*)$/)
    link = m.captures[0]
    link.gsub!(' ','%20')
    if ! link.start_with? 'http'
      link = URI.join(url, link)
    end
    graph[url].push link
  end
end

f = File.new('out.dot', 'w')
f.write "digraph G {\n"
graph.each do |k,v|
  v.each do |l|
    if graph.has_key?(l)
      f.write "  \"%s\" -> \"%s\";\n" % [k, l]
    end
  end
end
f.write('}')
f.close
