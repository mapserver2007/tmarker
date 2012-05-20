class DetailController < ViewController
  before_filter :open_validate

  def open_validate
    is_open = false
    user_name = current_user.login rescue nil
    merged_item.each do |e|
      # 登録ユーザとカレントユーザが一致した場合は公開
      if e.user.login == user_name
        is_open = true
        break
      # 登録ユーザとカレントユーザが一致しない場合
      else
        # 公開モードになっている場合
        if e.respond_to?(:open) && e.open
          is_open = true
          break
        # 非公開モードになっている場合
        else
          is_open = false
        end
      end
    end
    error unless is_open
  end

  def detail
    # main
    merged_items, @recommendations = merged_item, recommendation
    if merged_items.length != 0
      # item
      @items = merged_items[0]
      # wish
      @wish = wish?
      # referenced item count
      @item_count = referenced_item
      # reference user
      @users = user
      # side menu
      @development_log = development_log(5)
      @tracking_log = tracking_log(5)
      # title
      @title = application_title('message_detail_page', @items.item_title)
      @header_title = @items.item_title
      render :action => 'index'
    else
      error
    end
  end

  def image
    @item = merged_item[0]
    unless @item.nil?
      # title
      @title = application_title('message_detail_image', @item.item_title)
      @header_title = @item.item_title
      render :action => 'image'
    else
      error
    end
  end

  private

  def merged_item
    item.concat(wish)
  end

  def item
    super({:conditions => ['jancode = ?', params[:jancode]]})
  end

  def wish
    super({:conditions => ['jancode = ?', params[:jancode]]})
  end

  def user
    super(params[:jancode])
  end

  def referenced_item
    super({:conditions => ['jancode = ? AND open = ?', params[:jancode], true]})
  end

  def recommendation
    res = super({:conditions => ['item_id = ?', params[:jancode]]})
    res.empty? ? nil : res
  end

  def wish?
    begin
      conditions = ["users.login = ? AND jancode = ?", current_user.login, params[:jancode]]
      !(!!(Item.find(:all, {:include => :user, :conditions => conditions}).length > 0) or
        !!(Wish.find(:all, {:include => :user, :conditions => conditions}).length > 0))
    rescue
      false
    end
  end
end
