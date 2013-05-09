#!/usr/bin/env ruby
require './discovery'
require './fuzz_vectors'
require './sanitized_data'

class Crawler
	include Discovery
	include FuzzVectors
	include SanitizedData
	def initialize
		@configs = Configs.new
		@browser = Watir::Browser.new
		@discover_inputs_file =  File.open('inputs_report.txt', 'w')
		@vulnerabilities_file =  File.open('vulnerabilities_report.txt', 'w')
		@vulnerable_words_file =  File.open('vulnerable_data_found.txt', 'w')
		@test_forbidden = IO.readlines("sensitivedata.txt")
		@sanitized = IO.readlines("sanitizeddata.txt")
		@matches = IO.readlines("FuzzVectors/sql_match.txt")
		@sql = IO.readlines("FuzzVectors/SQL.txt")
		@xss = IO.readlines("FuzzVectors/XSS.txt")
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

					# now that @browser has navigated to the right webpage, let's scan the html
					# for data that should not be leaked
					@test_forbidden.each do |forbidden_data|
						forbidden_data_chomp = forbidden_data.chomp
						@vulnerable_words_file.write "Sensitive data '#{forbidden_data_chomp}' found in #{@browser.url}\n" if @browser.html.downcase.include? forbidden_data_chomp.downcase
					end

          			sleep @configs.wait_time
					login_pages(url, link_queue, paths_visited)
					inputs_found
				 	if @browser.text_fields.count > 0 and ((rand > 0.5 and not @configs.complete) or @configs.complete)
						@vulnerabilities_file.write("Vulnerabilities found on #{url}...\n")
						check_xss
						check_sql_injection
						check_sanitized_data
						@vulnerabilities_file.write("#{"-"*60}\n")
					end
				end
				@discover_inputs_file.write("#{"-"*60}\n")
			end
			cookies_found
		ensure
			@browser.close if not @browser.nil?
			@discover_inputs_file.close
			@vulnerable_words_file.close
			@vulnerabilities_file.close
		end
	end
end

crawler = Crawler.new
crawler.crawl
