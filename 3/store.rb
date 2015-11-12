#!/usr/bin/env ruby
require 'uri'
require 'yaml'

# Store class contains the K-V store of URLs and their links
class Store
  def initialize()
    @store = Hash.new
  end

  # Convert proto and DNS name to lowercase
  # Expects a fully qualified URL.
  def sanitise(url)
    if url and m = url.match(/(\w+)(:\/*)([\w\.\-].*)(\/?.*)?/)
      clean_url = m.captures[0].downcase + m.captures[1] + m.captures[2].downcase
      if m.captures[3]
        clean_url << m.captures[3]
      end
    else
      return nil
    end
  end

  # Add a URL and it's links to the store
  def add(url, children)
    @store[sanitise(url)] = Array.new
    # Add all unique linkes
    children.uniq.each do |c|
      @store[sanitise(url)].push(sanitise(c['href']))
    end
  end

  # Check for a URL in the store
  def exists?(url)
    return @store.has_key?(sanitise(url))
  end

  # Produces crawl.txt output
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
      links.each do |link|
        if @store.has_key?(link)
          if counts.has_key?(url)
            counts[url] += 1
          else
            counts[url] = 1
          end
        end
      end
      if ! counts.has_key?(url)
        counts[url] = 0
      end
    end

    to_return = ''
    counts.keys.sort.each do |url|
      to_return << url << "\n    " << counts[url].to_s << "\n"
    end
    to_return
  end
end
