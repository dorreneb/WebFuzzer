#!/usr/bin/env ruby

# A super simple test bench to execute features of the fuzzer.
# Add features by adding ["Prompt text", proc{method with code to call}] 
# to the options array.

def crawl
	puts "hello"
end

options = [["1) Crawl Webpage", proc{ crawl }], ["2) Quit", proc{ Process.exit }]]

while true
	puts "Pick an Option: "
	options.each { |option| puts option[0] }
	print "\nYour Option: "

	choice = gets.chomp.to_i
	
	options[choice-1][1].call; puts if choice <= options.count
end