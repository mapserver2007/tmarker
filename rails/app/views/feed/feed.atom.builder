set_all_item_data

atom_feed(:language => 'ja-JP',
          :root_url => site_url,
          :url      => atom_url,
          :id       => site_url) do |feed|
  feed.title    feed_title
  feed.subtitle feed_subtitile
  feed.updated  Time.now
  feed.author{|author| author.name(feed_author)}

  @items.length.times do |idx|
    set_item_data(idx)
    feed.entry(@item,
               :url       => entry_url(@item.jancode),
               :id        => entry_url(@item.jancode),
               :published => @item.register_date,
               :updated   => Time.now) do |item|
      item.title(@item.item_title)
      item.content(entry_description.join("<br/>"), :type => 'html')
      item.author{|author| author.name(@user.login) }
    end
  end
end