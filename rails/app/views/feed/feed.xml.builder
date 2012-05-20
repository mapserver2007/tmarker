xml.instruct!

set_all_item_data

xml.rss("version"    => "2.0",
        "xmlns:dc"   => "http://purl.org/dc/elements/1.1/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title       feed_title
    xml.link        site_url
    xml.pubDate     Time.now.rfc822
    xml.description feed_subtitile
    xml.atom :link, "href" => rss_url, "rel" => "self", "type" => "application/rss+xml"

    @items.length.times do |idx|
      set_item_data(idx)
      xml.item do
        xml.title        @item.item_title
        xml.link         entry_url(@item.jancode)
        xml.guid         entry_url(@item.jancode)
        xml.description  do xml.cdata! entry_description.join("<br/>") end
        xml.pubDate      @item.register_date
        xml.dc :creator, @user.login
      end
    end
  end
end