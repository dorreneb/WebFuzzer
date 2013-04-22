require 'nokogiri'
require 'open-uri'
require 'anemone'

def crawl_domain (domain)
	titles = []
	Anemone.crawl("http://www.example.com/") do |anemone|
  		anemone.on_every_page { |page| titles.push page.url rescue nil }
	end

	titles
end

def discover_links page
  doc = Nokogiri::HTML(open(page))
  doc.css('a').each do |link|
    puts "Link discovered: #{link.content} @URL= #{link.attr('href')}"
  end
end

discover_links 'http://localhost:8080/bodgeit'
print crawl_domain("google.com")
