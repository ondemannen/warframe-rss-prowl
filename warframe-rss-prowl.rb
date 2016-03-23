#!/usr/bin/ruby
# Checks warframe RSS feed and based on a regular expression search will notify you through ProwlApp
# Usage: ./warframe-rss-reader [<regexp search>] [prowl]
#        If no search is specified all events will show up
#        If the second argument is "prowl" the message will be sent through prowlapp
require 'rss'
require 'open-uri'

search = ARGV[0]
prowlit = ARGV[1] && ARGV[1].match(/prowl/) ? true : false

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
	def clr1; "\e[90m#{self}\e[0m" end  # gray
	def clr2;  "\e[91m#{self}\e[0m" end # red
	def clr3;  "\e[92m#{self}\e[0m" end # green
	def clr4;  "\e[93m#{self}\e[0m" end # yellow
	def clr5;  "\e[94m#{self}\e[0m" end # blue
	def clr6;  "\e[95m#{self}\e[0m" end # purple
	def clr7;  "\e[95m#{self}\e[0m" end # bright yellow
end

cmd = "/usr/local/bin/prowl.pl -apikey=#{prowl_api_key} -application=warframe -event='_EVENT_' -notification='_TEXT_'"

def pretty_colors(str)
	str.gsub!(/(\d+cr|\(\d+K\))/,'\1'.clr3)
	str.gsub!(/(\d?x? (Mutagen Mass|Fieldron|Detonite Injector|Mutalist Nav Coordinate))/i,'\1'.clr2)
	str.gsub!(/([\w\s]+ \(Aura\))/i,'\1'.clr5)
	str.gsub!(/([\w\s]+ \(Key\))/i,'\1'.clr7)
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
			if prowl_api_key && prowlit
				if(!done.include?(guid))
					`#{cmd.gsub(/_TEXT_/,item.title).gsub(/_EVENT_/,item.author)}`
					@fn.puts guid
				end
			else
				printf("%s, %s\n", item.author, pretty_colors(item.title))
			end
		end
	end
end
