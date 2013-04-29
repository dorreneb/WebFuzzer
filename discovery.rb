#!/usr/bin/env ruby

require 'set'
require 'open-uri'
require './custompages.rb'
require 'watir-webdriver'

class Crawler

	def initialize
		@custom_pages = CustomPages.new
		@max = 0;
	end

	def discover_all_inputs(root_url = "http://127.0.0.1")
		paths_visited = Set.new
		link_queue = []
		link_queue << root_url

		puts "Searching for inputs from root #{root_url}..."

		begin
			b = Watir::Browser.new 
			while (link_queue.size > 0)
				url = link_queue.pop
				puts "Scanning #{url}..."

				if @custom_pages.ignore_pages.include? url
					puts "\t#{url} has been flagged to be ignored."
				else
					b.goto url

					puts "\tNew Links:" if b.links.size > 0
					b.links.each do |link|
						href = link.href
						
						href_path = String.new(href)
						href_path.slice!(href_path.index('?')-1 ... href_path.size) if not href_path.index('?').nil?
						href_path.slice!(href_path.index(';')-1 ... href_path.size) if not href_path.index(';').nil?
						href_path.slice!(href_path.index('#')-1 ... href_path.size) if not href_path.index('#').nil?

						
						if not paths_visited.include? href_path and not (href.to_s =~ URI::regexp(["http", "https"])).nil?
							puts "\t\t#{href_path}"
							link_queue << href
							paths_visited << href_path
						end
					end
				end
				puts
			end
		rescue => error
			puts "#{error} (url: #{url}) (link: #{href})"
		ensure
			b.close if not b.nil?
		end
		
	end

	def discover_all_inputs_with_whitelist(root_url="http://127.0.0.1") 
		discover_all_inputs(root_url)
		@custom_pages.custom_scannable_pages.each do |page|
			discover_all_inputs(page)
		end
	end
end

puts "Enter URL root (Leave blank for 127.0.0.1):"
url = gets.chomp
url = "http://127.0.0.1" if url.nil? or url.empty?

crawl = Crawler.new
pages = crawl.discover_all_inputs(url)
	