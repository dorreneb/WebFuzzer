#!/usr/bin/env ruby

require 'set'
require 'open-uri'
require './configs'
require 'watir-webdriver'
require 'terminal-table'

class Crawler

	def initialize
		@configs = Configs.new
		@browser = Watir::Browser.new
		@discover_inputs_file =  File.open('inputs_report.txt', 'w')
	end

	def discover_all_inputs
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


	def is_same_domain(url1, url2)
		regex = /\/\/[A-Za-z0-9\.]*/
		url1.scan(regex).eql? url2.scan(regex)
	end

	def find_links(url, link_queue, paths_visited)
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
					@discover_inputs_file.write("\tFound #{href_path}\n")
					link_queue << href 			# keep full URL in case you need to pass args through
					paths_visited << href_path	# store base path so no duplicates happen
				end
			end
		end
	end

	def login(userfield, passfield, username, password)
		@discover_inputs_file.write("\t\tCredentials: #{username}/#{password}\n")

		@browser.text_field(:name, userfield).set(username)
    sleep @configs.wait_time
		@browser.text_field(:name, passfield).set(password)
    sleep @configs.wait_time
		@browser.input(:type=>"submit").click
    sleep @configs.wait_time
		@browser.url
	end

	def login_pages(url, link_queue, paths_visited)
		# if a link is marked as a login page feed it credentials and get the resulting page in the link queue
		if not @configs.login_pages[url].empty?
			new_loc = url

			# if password guessing is turned on, guess passwords
			if @configs.password_guessing
				@configs.common_passwords.each do |password|
					@discover_inputs_file.write("\t#{new_loc} is flagged as a login page.\n")
					creds = @configs.login_pages[new_loc]

					new_loc = login creds['userfield'], creds['passfield'], creds['username'], password
					break if not @browser.text_field(:name, creds["passfield"]).exists?
				end
			else
				@discover_inputs_file.write("\t#{url} is flagged as a login page.\n")
				creds = @configs.login_pages[url]
				@discover_inputs_file.write("\t\tCredentials: #{creds["username"]}/#{creds["password"]}\n")

				new_loc = login creds['userfield'], creds['passfield'], creds['username'], creds['password']
			end

			link_queue << new_loc if not link_queue.include? new_loc and not paths_visited.include? new_loc
		end
	end

	def inputs_found
		@discover_inputs_file.write("\n\tInputs Found:\n") if @browser.inputs.size > 0
		# pull inputs out of page
		@browser.inputs.each do |input|
			@discover_inputs_file.write("\t\tname: #{input.name}\n") if not input.name.empty?
			@discover_inputs_file.write("\t\ttype: #{input.type}\n") if not input.type.empty?
			@discover_inputs_file.write("\t\tvalue: #{input.value}\n") if not input.value.empty?
			@discover_inputs_file.write("\n")
		end
    sleep @configs.wait_time
	end

	def cookies_found
		# Now that we're done, let's print out all the cookies we found
		@discover_inputs_file.write("Cookies Found:\n")
		@browser.cookies.to_a.each do |cookie|
			@discover_inputs_file.write("\tname: #{cookie[:name]}\n")
			@discover_inputs_file.write("\tvalue: #{cookie[:value]}\n")
			@discover_inputs_file.write("\tpath: #{cookie[:path]}\n")
			@discover_inputs_file.write("\tdomain: #{cookie[:domain]}\n")
			@discover_inputs_file.write("\texpires: #{cookie[:expires]}\n")
			@discover_inputs_file.write("\tsecure: #{cookie[:secure]}\n")
			@discover_inputs_file.write("\n")
		end
    sleep @configs.wait_time
  end
end

crawl = Crawler.new
crawl.discover_all_inputs()
