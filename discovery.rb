require 'nokogiri'
require 'open-uri'
require 'anemone'

def crawl_domain (domain)
	titles = []
	Anemone.crawl('http://localhost:8080/bodgeit') do |anemone|
  		anemone.on_every_page { |page| titles.push page.url rescue nil }
	end

	titles
end

def discover_links(domain)
  Anemone.crawl(domain) do |anemone|
    anemone.on_every_page do |page| 
      puts "Discovered on #{page.url}"
      page.links.each do |x|
        puts x
      end
      puts
    end
  end
end

discover_links 'http://localhost:8080/bodgeit'