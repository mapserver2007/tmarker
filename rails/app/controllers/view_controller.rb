class ViewController < ApplicationController
  def item(opt = {})
    opt[:page]       = params[:page]
    opt[:per_page] ||= Setting.read_config('per_page')
    opt[:order]      = 'register_date DESC'
    opt[:include]    = [:group, :user]
    Item.paginate(opt)
  end

  def wish(opt = {})
    opt[:page]       = params[:page]
    opt[:per_page] ||= Setting.read_config('per_page')
    opt[:order]      = 'register_date DESC'
    opt[:include]    = [:group, :user]
    Wish.paginate(opt)
  end

  def group(id, opt = {})
    opt[:include] = [:group, :user]
    opt[:group]   = 'group_id'
    model = eval(id.gsub(/^./) {|e| e.upcase })
    model.find(:all, opt)
  end

  def user(jancode)
    Item.scoped_reference_user_by_jancode(jancode)
  end

  def recommendation(opt)
    Recommendation.find(:all, opt)
  end

  def lock(opt = {})
    opt[:conditions] = ["users.login = ? AND items.jancode = ?",
      params[:id], params[:jancode]]
    opt[:include] = [:group, :user]
    begin
      _item = Item.find(:all, opt)[0]
      _item.toggle!(:open)
      _item.open
    rescue
      nil
    end
  end

  def referenced_item(opt)
    Item.find(:all, opt).length
  end

  def referenced_wish(opt)
    Wish.find(:all, opt).length
  end

  def development_log(limit = nil)
    opt = {}
    unless limit.nil?
      opt[:limit] = limit
      opt[:offset] = 0
    end
    opt[:order] = 'log_id DESC'
    DevelopmentLog.find(:all, opt)
  end

  def tracking_log(limit = nil)
    opt = {}
    unless limit.nil?
      opt[:limit] = limit
      opt[:offset] = 0
    end
    opt[:order] = 'log_id DESC'
    TrackingLog.find(:all, opt)
  end

  def item_role
    [
      {:profile => current_user.profile_in_item},
      {:qrcode => current_user.qrcode_in_item},
      {:category_count => current_user.category_count_in_item},
      {:total_cost => current_user.total_cost_in_item},
      {:calendar => current_user.calendar_in_item}
    ]
  end

  def wish_role
    [
      {:category_count => current_user.category_count_in_wish},
      {:calendar => current_user.calendar_in_wish}
    ]
  end

  def feed(data)
    @items = data
    respond_to do |format|
      format.xml  {render :action => 'feed.xml'}
      format.atom {render :action => 'feed.atom'}
    end
  end

  def feed_error
    respond_to do |format|
      format.xml  {render :action => 'feed_error.xml'}
      format.atom {render :action => 'feed_error.atom'}
    end
  end
end
