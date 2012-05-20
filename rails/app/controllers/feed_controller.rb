class FeedController < ViewController
  helper :feed
  before_filter :feed_header

  include Tmarker::Common::Util

  def feed_header
    @feed_header = super
    @accesskey = params[:accesskey]
    @func = params[:func]
  end

  def public_feed
    feed(item({:conditions => ["items.open = ?", true]}))
  end

  def private_feed
    if valid_func?(@func)
      private_feed_by_item if @func == 'item'
      private_feed_by_wish if @func == 'wish'
    else
      feed_error
    end
  end

  def private_feed_by_item
    @user = User.find_by_accesskey(@accesskey)
    unless @user.nil?
      feed(item({:conditions => ["items.open = ? AND users.accesskey = ?",
        true, @accesskey], :per_page => @user.page_in_item}))
    else
      feed_error
    end
  end

  def private_feed_by_wish
    @user = User.find_by_accesskey(@accesskey)
    unless @user.nil?
      feed(wish({:conditions => ["users.accesskey = ?",
        @accesskey], :per_page => @user.page_in_wish}))
    else
      feed_error
    end
  end
end