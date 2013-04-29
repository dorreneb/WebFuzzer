require 'Anemone'
require 'set'
require 'open-uri'

class Crawler

	def discover_pages(domain)
		titles = Set.new

		Anemone.crawl(domain) do |anemone|
	  		anemone.on_every_page do |page|
	  			url = page.url
	  			titles.add ("#{url.host}:#{url.port}#{url.path}") if not page.doc.nil?
  			end
		end

		titles
	end

	def discover_inputs(page_url = "http://127.0.0.1")
		inputs = []
 
		puts "Searching #{page_url}..."
		page = Nokogiri::HTML(open(page_url)) 
		page.xpath("//input").each do |input|
			inputs.add input
		end
		
		inputs
	end

	#
	# I don't reuse code from discover_pages and discover_inputs here because it is fairly 
	# expensive to open nokogiri pages. Utilizing the pages that are already open when 
	# Anemone is crawling makes it faster when fuzzing large websites. Consider discover_pages 
	# and discover_inputs learning exercises while getting to discover_all_inputs.
	#
	def discover_all_inputs(root_url = "http://127.0.0.1")
		visited_pages = Set.new

		puts "Searching for inputs from root #{root_url}..."
		Anemone.crawl(root_url) do |anemone|
	  		anemone.on_every_page do |page|
	  			url = "#{page.url.host}:#{page.url.port}#{page.url.path}"

	  			# only search on pages that have not yet been fuzzed
	  			if not visited_pages.include? url
	  				# search page
		  			puts "\tSearching #{url}..."
		  			if not page.doc.nil?
		  				# print inputs
		  				inputs = page.doc.xpath("//input")
		  				puts "\t\tInputs:" if inputs.size > 0
		  				inputs.each { |input| puts "\t\t\t#{input}" }
		  				
		  				# print cookies (if exist)
		  				if page.cookies.size > 0
		  					puts "\t\tCookies:"
		  					page.cookies.each { |cookie| puts "\t\t\t#{cookie}"}
		  				end
		  			end

		  			#mark page as visited
		  			visited_pages.add url
		  		end
  			end
		end
	end

end