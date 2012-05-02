require 'rubygems'
require 'digest/md5'
require 'pp'

def get_links(doc)
  doc.css("a").map do |link|
    if (href = link.attr("href")) && href.match(/^https?:/)
      href
    end
  end.compact
end

def frequencies(words)
  Hash[
    words.group_by(&:downcase).map{ |word,instances|
      [word,instances.length]
    }.sort_by(&:last).reverse
  ]
end

def add_redis_done(page)
  md5_link =  Digest::MD5.hexdigest(page.url.to_s)
  if !$r.exists("l:#{md5_link}")
    $r.hset("l:#{md5_link}", "url", page.url)
    $r.hset("l:#{md5_link}", "title", page.doc.title)
    $r.hset("l:#{md5_link}", "status", page.code)
    $r.hset("l:#{md5_link}", "title", page.doc.title)
    $r.hset("l:#{md5_link}", "title", page.doc.title)
    $r.hset("l:#{md5_link}", "last", Time.now.inspect)
    $r.sadd("done", "l:#{md5_link}")
    puts "NEW -> #{link}"
  else
    $r.srem("queue", "l:#{md5_link}")
    $r.sadd("done", "l:#{md5_link}")
    puts "old -> #{link}"
  end
end

def add_redis_queue(link)
  md5_link =  Digest::MD5.hexdigest(link.to_s)
  if !$r.exists("l:#{md5_link}")
    $r.hset("l:#{md5_link}", "url", link)
    $r.hset("l:#{md5_link}", "last", Time.now.inspect)
    $r.sadd("queue", "l:#{md5_link}")
    puts "NEW -> #{link}"
  else
    puts "old -> #{link}"
    $r.hset("l:#{md5_link}", "last", Time.now.inspect)
  end
end

def nokogiri_parse(html)
  html.css('script').each(&:remove)
  text  = html.at('body').inner_text
  #words = html.at('body').inner_text.scan(/\w+/)
  #pp frequencies(words)
end