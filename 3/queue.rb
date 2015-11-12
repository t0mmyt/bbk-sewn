#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/page.rb'

class Queue
  def initialize(seed, ttl, robots, store, restrict)
    @store = store
    @queue = Array.new
    @robots = robots
    @restrict = restrict
    self.push(seed, ttl)
    until @queue.length <= 0
      puts "QueueLen:" + @queue.length.to_s
      self.shift
    end
  end

  def push(url, ttl)
    url= @store.sanitise(url)
    # Is it in robots?
    robot = false
    @robots.each do |r|
      if url.start_with?(r)
        robot = true
      end
    end
    # Do we already have it?, Is it in robots.txt?, Is it within our restriction
    exists = @store.exists?(url)
    if !exists and url.start_with?(@restrict) and !robot
      puts "-> QUEUE: %3d %s" % [ttl, url]
      @queue.push({
        'url'     => url,
        'ttl'     => ttl })
      end
  end

  def shift()
    # If our ttl is zero, skip
    if @queue.length < 1
      return nil
    end
    # Get next from queue
    this = @queue.shift
    puts "QUEUE ->: %3d %s" % [this['ttl'], this['url']]
    # Do we already have this page?
    if ! @store.exists?(this['url'])
      # Get page and read links
      p = Page.new(this['url'], nil, this['ttl'])
      # Add each link to the queue (if it doesn't alreaady exist)
      p.links.each do |l|
        if l['ttl'] > 0 and !@store.exists?(l['href'])
          self.push(l['href'], l['ttl'])
        end
      end
      # Store the links
      @store.add(this['url'],  p.links)
    end
  end
end
