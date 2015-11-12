#!/usr/bin/env ruby
require 'uri'
require 'yaml'

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
    @store[sanitise(url)] = Array.new
    # Add all unique linkes
    children.uniq.each do |c|
      @store[sanitise(url)].push(sanitise(c['href']))
    end
  end

  def exists?(url)
    return @store.has_key?(sanitise(url))
  end

  def dump()
    to_return = String.new
    @store.keys.sort.each do |k|
      to_return << k << "\n"
      @store[k].sort.each do |l|
        to_return << "      " << l << "\n"
      end
    end
    to_return
  end

  def count()
    counts = Hash.new
    @store.each do |url,links|
      links.each do |url|
        if counts.has_key?(url)
          counts[url] += 1
        elsif self.exists?(url)
          counts[url] = 1
        end
      end
    end
    to_return = ''
    counts.keys.sort.each do |url|
      to_return << url << "\n    " << counts[url].to_s << "\n"
    end
    to_return
  end
end
