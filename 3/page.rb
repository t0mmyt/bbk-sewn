#!/usr/bin/env ruby
require 'nokogiri'
require 'net/http'
require 'uri'

class Page
  def initialize(url, robots, ttl)
    @links = Array.new
    @base_url = url[0, url.rindex('/', -1) + 1]
    @ttl = ttl
    # puts "PAGE TTL:  " + @ttl.to_s + " BASE: " + @base_url
    parse_links(get(url), ttl)
  end

  def get(url)
    puts "HTTP GET:  " + url
    Net::HTTP.get(URI(url))
  end

  def parse_links(html, ttl)
    doc = Nokogiri::HTML(html)
    doc.css('a').each do |a|
      my_ttl = ttl
      href = a.attribute('href').to_s
      # Use URI.join to dispose of nasty relative hrefs
      href = URI.join(@base_url, href).to_s

      match = href.match(/(\w+):/)
      proto = match.captures[0]

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
