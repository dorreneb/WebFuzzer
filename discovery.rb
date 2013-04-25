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

def discover_links(domain, common_url_path)
  pages = read_page_guesses(common_url_path)
  Anemone.crawl(domain) do |anemone|
    anemone.on_every_page do |page|
      puts "Discovered on #{page.url}"
      page.links.each do |x|
        puts x
        pages[x.path] = true
      end
      puts
    end
  end
  puts "Pages not linked"
  pages.each do |k, v|
    puts k if !v
  end
end

def read_page_guesses(common_url_path)
  hash = Hash.new
  open(common_url_path).each do |line|
    hash[line.chomp] = false
  end
  hash
end

discover_links 'http://localhost:8080/bodgeit', 'commonurls-bodgeit.txt'