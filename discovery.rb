#!/usr/bin/env ruby

require 'set'
require 'open-uri'
require './configs'
require 'watir-webdriver'

class Crawler

	def initialize
		@configs = Configs.new
		@browser = Watir::Browser.new
	end

	def discover_all_inputs()
		paths_visited = Set.new
		link_queue = []
		link_queue << @configs.root_url
		@browser.cookies.clear

		puts "Searching for inputs from root #{@configs.root_url}..."

		begin
			while (link_queue.size > 0)
				url = link_queue.pop
				puts "Scanning #{url}..."

				if @configs.ignore_pages.include? url
					puts "\t#{url} has been flagged to be ignored."
				else
					# Go to next page
					@browser.goto url

					# Get the links to keep navigating
					@browser.links.each do |link|
						#grab link address
						href = link.href

						# if the link is valid set it to traverse
						if not (href.to_s =~ URI::regexp(["http", "https"])).nil?

							#get the base webpage so we don't keep navigating to duplicate pages
							href_path = String.new(href)
							href_path.slice!(href_path.index('?') ... href_path.size) if not href_path.index('?').nil?
							href_path.slice!(href_path.index(';') ... href_path.size) if not href_path.index(';').nil?
							href_path.slice!(href_path.index('#') ... href_path.size) if not href_path.index('#').nil?


							# if a link is legit and hasn't been visited yet throw it on the stack
							# for a link to be legit it must be in the same domain
							if not paths_visited.include? href_path and is_same_domain(href, url)
								puts "\tFound #{href_path}"
								link_queue << href 			# keep full URL in case you need to pass args through
								paths_visited << href_path	# store base path so no duplicates happen
							end
						end
					end
          sleep @configs.wait_time

					# if a link is marked as a login page feed it credentials and get the resulting page in the link queue
					if not @configs.login_pages[url].empty?
						puts "\t#{url} is flagged as a login page."
						creds = @configs.login_pages[url]
						puts "\t\tCredentials: #{creds["username"]}/#{creds["password"]}"

						@browser.text_field(:name, creds["userfield"]).set(creds["username"])
            sleep @configs.wait_time
						@browser.text_field(:name, creds["passfield"]).set(creds["password"])
            sleep @configs.wait_time
						@browser.input(:type=>"submit").click
            sleep @configs.wait_time
						new_loc = @browser.url

						link_queue << new_loc if not link_queue.include? new_loc and not paths_visited.include? new_loc
					end

					puts "\tInputs Found:" if @browser.inputs.size > 0
					# pull inputs out of page
					@browser.inputs.each do |input|
						puts "\t\t#{input.html}"
					end
          sleep @configs.wait_time
				end
			end

			# Now that we're done, let's print out all the cookies we found
			puts "Cookies Found:"
			@browser.cookies.to_a.each { |cookie|puts "\t#{cookie}" }
      sleep @configs.wait_time
		rescue => error
			puts error
		ensure
			@browser.close if not @browser.nil?
		end
	end


	def is_same_domain(url1, url2)
		regex = /\/\/[A-Za-z0-9\.]*/
		url1.scan(regex).eql? url2.scan(regex)
	end

end

crawl = Crawler.new
crawl.discover_all_inputs()
