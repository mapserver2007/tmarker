xml.instruct!

xml.rss("version"    => "2.0",
        "xmlns:dc"   => "http://purl.org/dc/elements/1.1/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title       error_feed_title
    xml.link        site_url
    xml.pubDate     Time.now.rfc822
    xml.description error_feed_description
    xml.atom :link, "type" => "application/rss+xml"
  end
end