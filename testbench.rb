#!/usr/bin/env ruby

require './discovery.rb'

# A super simple test bench to execute features of the fuzzer.
# Add features by adding ["index) prompt text", proc{method with code to call}] 
# to the options array.

def crawl
	puts "Enter URL root (Leave blank for 127.0.0.1):"
	url = gets.chomp
	url = "http://127.0.0.1" if url.nil? or url.empty?

	crawl = Crawler.new
	pages = crawl.discover_pages(url)

	pages.each { |url|	puts url } if not pages.nil?
end

def get_inputs
	puts "What URL do you want to get inputs from? (Leave blank to use results of crawl): " 
	url = gets.chomp

	crawl = Crawler.new
	inputs = crawl.discover_inputs(url)

	inputs.each { |input| puts input } if not inputs.nil?

end

def get_all_inputs
	puts "Enter URL root (Leave blank for 127.0.0.1):"
	url = gets.chomp
	url = "http://127.0.0.1" if url.nil? or url.empty?

	crawl = Crawler.new
	pages = crawl.discover_all_inputs(url)
end

options = [
	["1) Crawl Webpage", proc{ crawl }], 
	["2) Get Inputs from Page", proc{ get_inputs }], 
	["3) Get Inputs from Crawl", proc{ get_all_inputs }],
	["4) Quit", proc{ Process.exit }]]

while true
	puts "Pick an Option: "
	options.each { |option| puts option[0] }
	print "\nYour Option: "

	choice = gets.chomp.to_i
	
	options[choice-1][1].call; puts if choice <= options.count
end