#!/usr/bin/env ruby
require 'yaml'
require 'nokogiri'
require 'net/http'

class Store
  def initialize()
    @store = Hash.new
  end

  def sanitise(url)
    # Convert proto and DNS name to lowercase
    # Expects a fully qualified URL.
    if url and m = url.match(/(\w+)(:\/*)([\w\.\-].*)(\/?.*)?/)
      clean_url = m.captures[0].downcase + m.captures[1] + m.captures[2].downcase
      if m.captures[3]
        clean_url << m.captures[3]
      end
    else
      return nil
    end
  end

  def add(url, children)
    sanitised_children = Array.new
    children.each do |c|
      sanitised_children.push(sanitise(c['href']))
    end

    @store[sanitise(url)] = sanitised_children
  end

  def exists?(url)
    @store.has_key?(sanitise(url))
  end

  def dump()
    YAML.dump(@store)
  end
end

class Queue
  def initialize(seed, ttl, store)
    @store = store
    @queue = Array.new
    self.push(seed, ttl)
    until ! self.shift()
    end
  end

  def push(url, ttl)
    if ! @store.exists?(url)
      @queue.push({
        'url'     => url,
        'ttl'     => ttl })
      end
  end

  def shift()
    if @queue.length < 1
      return nil
    else
      puts "QUEUE:" + @queue.length.to_s
    end

    this = @queue.shift
    p = Page.new(this['url'], nil, this['ttl'])
    p.links.each do |l|
      # puts "LINK: " + l['href'] + " ttl:" + l['ttl'].to_s
      if l['ttl'] > 0
        self.push(l['href'], l['ttl'])
      end
    end
    @store.add(this['url'],  p.links)
  end
end


class Page
  def initialize(url, robots, ttl)
    @links = Array.new
    @base_url = url[0, url.rindex('/', -1) + 1]
    @ttl = ttl
    puts "TTL:  " + @ttl.to_s + " BASE: " + @base_url
    parse_links(get(url), ttl)
  end

  def get(url)
    puts "GET:  " + url
    Net::HTTP.get(URI(url))
  end

  def parse_links(html, ttl)
    doc = Nokogiri::HTML(html)
    doc.css('a').each do |a|
      my_ttl = ttl
      href = a.attribute('href').to_s
      # Relative or Absolute URL?
      if match = href.match(/(\w+):/)
        # This was a full URL
        proto = match.captures[0]
      else
        # This was a relative URL
        href = @base_url + href
        match = href.match(/(\w+):/)
        proto = match.captures[0]
      end
      if my_ttl > 0
        # Are we http(s)?
        if proto.downcase.start_with?('http')
          # http(s) found so decrement TTL
          my_ttl -= 1
        else
          # not http(s) so add with a ttl of 0
          my_ttl = 0
        end
      end
      # Link parsed so add it to the list
      @links.push({'href' => href, 'ttl' => my_ttl})
    end
  end

  def links()
    return @links
  end
end

s = Store.new
q = Queue.new('http://www.dcs.bbk.ac.uk/~martin/sewn/ls3', 4, s)

puts s.dump
