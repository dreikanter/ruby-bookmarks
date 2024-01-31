require 'kramdown'
require 'nokogiri'
require 'open-uri'

file_path = 'README.md'
puts '-------- Reading file -----------'
markdown = File.read(file_path)

sleep(1)
puts '-------- Converting to HTML -----------'
converted_html = Kramdown::Document.new(markdown).to_html

sleep(1)
puts '-------- Parsing HTML -----------'
parsed_html = Nokogiri::HTML.parse(converted_html)

sleep(1)
puts '-------- Reading Links -----------'
links = parsed_html.xpath("//a").map do |anchor| 
  if anchor.attributes && anchor.attributes["href"] && !anchor.attributes["href"].value.match?(/^(#)/)
    anchor.attributes["href"].value
  end
end.compact.uniq

validity_hash = {}
failed_links = []

sleep(1)
puts '-------- Excluding website of specific domains -----------'
exclude_websites = ['amazon.com', 'reddit.com']
exclude_websites_regex = /\b(#{exclude_websites.join("|")})\b/

#NOTE: amazon, reddit urls will give 503 or 404 errors but they're working from browsers
## this is to prevent crawling
# Although we can bypass this but it would be an overkill
#
sleep(1)
puts '-------- Fetching links -----------'
links.select { |url| !url.match?(exclude_websites_regex) }.each_with_index do |url, index|
  print '.'
  print "\n" if index % 36 == 0 
  begin
    response = open(url)
    #uncomment if you want to see successful urls as well
    #puts "URL: #{url} || STATUS: #{response.status[0]}"
    validity_hash[url] = response.status[0]
  rescue StandardError => error
    puts "\nURL: #{url} || STATUS: #{error}"
    failed_links << url
  end
end
puts '-------- Finished -----------'