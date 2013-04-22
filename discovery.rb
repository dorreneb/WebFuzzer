require 'Anemone'

def crawl_domain (domain)
	titles = []
	Anemone.crawl("http://www.example.com/") do |anemone|
  		anemone.on_every_page { |page| titles.push page.url rescue nil }
	end

	titles
end

print crawl_domain("google.com")