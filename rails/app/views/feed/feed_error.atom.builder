atom_feed(:language => 'ja-JP',
          :root_url => site_url,
          :id       => site_url) do |feed|
  feed.title    error_feed_title
  feed.subtitle error_feed_description
  feed.updated  Time.now
  feed.author{|author| author.name(feed_author)}
end