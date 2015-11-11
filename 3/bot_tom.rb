#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require File.dirname(__FILE__) + '/store.rb'
require File.dirname(__FILE__) + '/queue.rb'
require File.dirname(__FILE__) + '/page.rb'

# Define our URLs
seed_url = 'http://www.dcs.bbk.ac.uk/~martin/sewn/ls3'
robots_url = 'http://www.dcs.bbk.ac.uk/~martin/sewn/ls3/robots.txt'

# Get robots
raw_robots = Net::HTTP.get(URI(robots_url)).to_s
robots = Array.new
# Hack because robots is a bit wrong
this_is_really_dirty = seed_url
raw_robots.each_line do |r|
  r.strip!
  if m = r.match(/^Disallow:\s+(.*)/)
    robots.push(this_is_really_dirty + m.captures[0])
  end
end

store = Store.new
q = Queue.new(seed='http://www.dcs.bbk.ac.uk/~martin/sewn/ls3/', ttl=10, robots=robots, store=store, restrict=seed_url)

f = File.new('crawl.txt', 'w')
f.write store.dump
f.close

f = File.new('results.txt', 'w')
f.write store.count
f.close
