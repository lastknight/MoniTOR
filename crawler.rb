require 'rubygems'
require 'anemone'
require "redis"

require 'lib/functions'

$r = Redis.new(:host => "gar.redistogo.com", :port => 9141, :password => "4a3e1c1340bbaf7fb5120067b8d7644a")
$r.flushdb

#Anemone.crawl("http://www.mgpf.it/", :proxy_host => "localhost", :proxy_port => 9050) do |anemone|
Anemone.crawl("http://mgpf.it") do |anemone|
  anemone.on_every_page do |page|
    puts "Indexing -> #{page.url}"
    puts page.code
    puts page.url
    puts page.doc.title
    puts nokogiri_parse(page.doc)              # Parsing with NokoGiri
    get_links(page.doc).each do |link|    # Getting all the links  
      add_redis_queue(link)               # Adding to queue
    end
    puts "\n\n\n"
  end
end


__END__
# require 'webtagger'
#      tags = WebTagger.tag_with_tagthe(page.doc.text)
#      puts tags
#      puts page.headers
