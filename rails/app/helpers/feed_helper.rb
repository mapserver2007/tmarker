module FeedHelper
  def rss
    link_to(image_tag(m('logo_rss')), feed_url(:format => 'xml'), :class => "rss")
  end

  def atom
    link_to(image_tag(m('logo_atom')), feed_url(:format => 'atom'), :class => "rss")
  end

  def my_rss
    link_to(image_tag(m('logo_rss')), myfeed_url(:accesskey => @accesskey,
      :func => @page_name, :format => 'xml'), :class => "rss")
  end

  def my_atom
    link_to(image_tag(m('logo_atom')), myfeed_url(:accesskey => @accesskey,
      :func => @page_name, :format => 'atom'), :class => "rss")
  end

  def generate_feed_header
    @site_url = @feed_header["site_url"]
    @rss_url  = !@user.nil? ? @feed_header["my_rss_url"] % [@user.login, @func] : @feed_header["rss_url"]
    @atom_url = !@user.nil? ? @feed_header["my_atom_url"] % [@user.login, @func] : @feed_header["atom_url"]
  end

  def site_url
    @feed_header["site_url"]
  end

  def rss_url
    !@user.nil? ? @feed_header["my_rss_url"] % [@accesskey, @func] : @feed_header["rss_url"]
  end

  def atom_url
    !@user.nil? ? @feed_header["my_atom_url"] % [@accesskey, @func] : @feed_header["atom_url"]
  end

  def feed_title
    !@user.nil? ? @feed_header["my_site_title"] % @user.login : @feed_header["site_title"]
  end

  def feed_subtitile
    !@user.nil? ? @feed_header["my_site_subtitle"] % @user.login : @feed_header["site_subtitle"]
  end

  def feed_author
    @feed_header["feed_author"]
  end

  def entry_url(id)
    site_url + 'detail/' + id
  end

  def entry_description
    description = []
    description << generate_category[:image] + link_to(@item.item_title, @item.item_link)
    unless @item.item_image_medium.nil?
      description << link_to(image_tag(@item.item_image_medium), @item.item_link)
    else
      description << image_tag(m('item_no_image_large'))
    end
    description << item_publisher(200)
    description << item_price
    description << item_release_date
    description
  end

  def error_feed_title
    @feed_header["error_site_title"]
  end

  def error_feed_description
    @feed_header["error_site_description"]
  end
end
