#!/usr/bin/env ruby
require './discovery'
require './fuzz_vectors'

class Crawler
	include Discovery
	include FuzzVectors
	def initialize
		@configs = Configs.new
		@browser = Watir::Browser.new
		@discover_inputs_file =  File.open('inputs_report.txt', 'w')
		@vulnerabilities_file =  File.open('vulnerabilities_report.txt', 'w')
	end

	def crawl
		paths_visited = Set.new
		link_queue = []
		link_queue << @configs.root_url
		link_queue.concat(@configs.custom_scannable_pages)
		@browser.cookies.clear

		@discover_inputs_file.write("Searching for inputs from root #{@configs.root_url}...\n")

		begin
			while (link_queue.size > 0)
				url = link_queue.pop
				@discover_inputs_file.write("Scanning #{url}...\n")

				if @configs.ignore_pages.include? url
					@discover_inputs_file.write("\t#{url} has been flagged to be ignored.\n")
				else
					find_links(url, link_queue, paths_visited)
          sleep @configs.wait_time
					login_pages(url, link_queue, paths_visited)
					inputs_found
				 	if @browser.text_fields.count > 0 and ((rand > 0.5 and not @configs.complete) or @configs.complete)
						@vulnerabilities_file.write("Vulnerabilities found on #{url}...\n")
						xss
						# sql
						@vulnerabilities_file.write("#{"-"*60}\n")
					end
				end
				@discover_inputs_file.write("#{"-"*60}\n")
			end
			cookies_found
		rescue => error
			puts error
		ensure
			@browser.close if not @browser.nil?
			@discover_inputs_file.close
		end
	end
end

crawl = Crawler.new
crawl.crawl