#!/usr/bin/ruby
# Checks warframe RSS feed and based on a regular expression search will notify you through ProwlApp
# Usage: ./warframe-rss-reader [regexp search] [no]
#        If no search is specified all events will show up
#        If the second argument is present the message will not be sent through prowlapp
require 'rss'
require 'open-uri'

search = ARGV[0]
no_send = ARGV[1]

url = "http://content.warframe.com/dynamic/rss.php?#{Random.new_seed}"

prowl_api_key = nil
if File.exist?(File.expand_path("~/etc/prowl.cfg"))
	# Create the file in ~/etc and just copy the prowl API key into it
	prowl_api_key = File.open(File.expand_path("~/etc/prowl.cfg")).read.chomp
end

done = []
saved = '/tmp/.warframe.rss'
if File.exist?(saved)
	fn = File.open(saved, "r")
	fn.each do |l|
		done << l.chomp
	end
end
@fn = File.open(saved, "a")

class String
	def clr1; "\e[32m#{self}\e[0m" end
	def clr2;  "\e[33m#{self}\e[0m" end
	def clr3;  "\e[34m#{self}\e[0m" end
	def clr4;  "\e[35m#{self}\e[0m" end
end

cmd = "/usr/local/bin/prowl.pl -apikey=#{prowl_api_key} -application=warframe -event=alert -notification='_XXX_'"

def pretty_colors(str)
	str.gsub!(/(\d+cr|\(\d+K\))/,'\1'.clr1)
	str.gsub!(/(\d?x? Mutagen Mass)/i,'\1'.clr2)
	str.gsub!(/(\d?x? Detonite Injector)/i,'\1'.clr3)
	str
end

open(url) do |rss|
	feed = RSS::Parser.parse(rss)
	feed.items.each do |item|
		if !search
			printf("%s (%s)\n", item.author, pretty_colors(item.title))
			next
		elsif item.title.match(/#{search}/i)
			guid = item.guid.to_s.gsub(/<.*?>(.*)<.*?>/,'\1')
			if prowl_api_key && !no_send
				if(!done.include?(guid))
					`#{cmd.gsub(/_XXX_/,item.title)}`
					@fn.puts guid
				end
			else
				printf("%s, %s\n", item.author, pretty_colors(item.title))
			end
		end
	end
end
