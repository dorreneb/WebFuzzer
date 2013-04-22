require 'nokogiri'
require 'open-uri'

def discover_links page
  doc = Nokogiri::HTML(open(page))
  doc.css('a').each do |link|
    puts "Link dsicovered: #{link.content} @URL= #{link.attr('href')}"
  end
end

discover_links 'http://localhost:8080/bodgeit'