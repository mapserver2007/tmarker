require 'uri'

class MypageController < ViewController
  helper :mypage, :feed
  before_filter :session_validate, :redirect_to_saved_tab

  def session_validate
    url = url_for({
      :controller => params[:controller],
      :action => params[:action],
      :id => params[:id]
    })
    super(url)
  end

  def redirect_to_saved_tab
    unless current_user.nil? || request.referer.nil?
      uri = URI.parse(request.referer)
      if uri.path == '/'
        if !session[:tab_id].nil? && session[:tab_id] != params[:action]
          url = url_for({
            :controller => params[:controller],
            :action => session[:tab_id],
            :id => params[:id]
          })
          redirect_to(url)
        end
      end
    end
  end

  def item(cond = nil, args = [], param = {})
    @users = User.find_by_login(params[:id])
    conditions = generate_condition(cond, args, current_method)
    @items = super({:conditions => conditions, :per_page => @users.page_in_item})
    param[:page_name] = current_method
    param[:title] = 'message_your_item'
    describe_index(param)
  end

  def wish(cond = nil, args = [], param = {})
    @users = User.find_by_login(params[:id])
    conditions = generate_condition(cond, args, current_method)
    @items = super({:conditions => conditions, :per_page => @users.page_in_wish})
    param[:page_name] = current_method
    param[:title] = 'message_your_wish'
    describe_wish(param)
  end

  def register(param = {})
    unless params[:jancode].nil?
      require 'services/bridge'
      require 'models/common/db'
      bridge = Tmarker::Bridge.new
      @items = bridge.service_item(params[:jancode], 'wish')
      param[:item_count] = item_count
      param[:non_register] = non_register?
    end
    param[:page_name] = current_method
    param[:title] = 'message_your_register'
    describe_register(param)
  end

  def download(param = {})
    param[:page_name] = current_method
    param[:title] = 'message_your_download'
    describe_download(param)
  end

  def download_gm
    f = open(path_to_extension + "/gm/#{params[:file]}")
    render :text => f.read
  end

  def download_addon
    require 'find'
    relative_path = nil
    Find.find(File.expand_path(path_to_extension)) do |path|
      if /#{params[:file]}$/ =~ path
        sub_dir = []
        dir = path.split("/").reverse
        5.times do |i|
          sub_dir << dir[i]
        end
        relative_path = sub_dir.reverse.join("/")
      end
    end
    unless relative_path.nil?
      redirect_to url_for_apache + relative_path
    else
      error
    end
  end

  def blogparts(param = {})
    @result    = {}
    @result    = save_access?(params[:site]) unless params[:site].nil?
    @parts_url = {:item => blogparts_url_for_item, :wish => blogparts_url_for_wish}
    @sites     = blogparts_sites
    param[:page_name] = current_method
    param[:title] = 'message_your_blogparts'
    describe_blogparts(param)
  end

  def save_access?(sites)
    result = {}
    begin
      sites.each do |result[:allow_id], result[:allow_url]|
        user = User.find_by_login(current_user.login)
        result[:user_id] = user.id
        if result[:allow_url].empty?
          access = Access.find_by_user_id_and_allow_id(result[:user_id], result[:allow_id])
          access.destroy unless access.nil?
        else
          begin
            # insert record
            access = Access.new(result)
            access.save!
          rescue ActiveRecord::StatementInvalid
            # update record
            access = Access.find_by_user_id_and_allow_id(result[:user_id], result[:allow_id])
            access.allow_url = result[:allow_url]
            access.save!
          end
        end
      end
      result[:save] = true
    rescue ActiveRecord::RecordInvalid => e
      result[:save] = false
      result[:message] = e.message
    end
    result
  end

  def blogparts_url_for_item
    blogparts_url('item')
  end

  def blogparts_url_for_wish
    blogparts_url('wish')
  end

  def blogparts_url(func)
    user = User.find_by_login(current_user.login)
    url = m('url_blogparts') % [user.accesskey, func, m('blogparts_default_width'), m('blogparts_default_count')]
    "<script language=\"javascript\" type=\"text/javascript\" charset=\"UTF-8\" src=\"#{url}\"></script>"
  end

  def blogparts_sites
    sites = Array.new(3)
    user = User.find_by_login(current_user.login)
    access = Access.find(:all, :conditions => ["user_id = ?", user.id])
    access.each do |e|
      sites[e.allow_id - 1] = e.allow_url
    end
    sites
  end

  def qrcode
    Mypage.current_user = current_user.login
    begin
      raise if params[:id] != current_user.login
      send_data(Mypage.qrcode({:size => 180, :charset => "UTF-8"}),
        :disposition => "inline", :type => "image/png")
    rescue
      send_data(Mypage.qrcode_failure(m('item_no_image_large')),
        :disposition => "inline", :type => "image/gif")
    end
  end

  def item_count
    referenced_item({:conditions => ['jancode = ?', params[:jancode]]})
  end

  def non_register?
    referenced_wish({:conditions => ['users.login = ? AND jancode = ?',
      params[:id], params[:jancode]], :include => [:group, :user]}) == 0
  end

  def item_by_price
    stmt, bind = price
    !stmt.nil? || !bind.nil? ? item(stmt, bind) : error
  end

  def wish_by_price
    stmt, bind = price
    !stmt.nil? || !bind.nil? ? wish(stmt, bind) : error
  end

  def item_by_category
    stmt, bind = category
    !stmt.nil? || !bind.nil? ? item(stmt, bind) : error
  end

  def wish_by_category
    stmt, bind = category
    !stmt.nil? || !bind.nil? ? wish(stmt, bind) : error
  end

  def item_by_calendar
    stmt, bind, date_obj = calendar
    !stmt.nil? || !bind.nil? ? item(stmt, bind, date_obj) : error
  end

  def wish_by_calendar
    stmt, bind, date_obj = calendar
    !stmt.nil? || !bind.nil? ? wish(stmt, bind, date_obj) : error
  end

  def category
    return "groups.product_name = ?", params[:name]
  end

  def price
    if Mypage.price?({:low => params[:low_price], :high => params[:high_price]})
      if (params[:low_price].nil?)
        return "%s.item_price BETWEEN 0 AND ?", params[:high_price]
      elsif (params[:high_price].nil?)
        return "%s.item_price BETWEEN ? AND 100000", params[:low_price]
      else
        return "%s.item_price BETWEEN ? AND ?", [params[:low_price], params[:high_price]]
      end
    end
  end

  def calendar
    if (params[:date] =~ /^[\d]+$/ && (params[:date].length == 6 || params[:date].length == 8))
      date = params[:date].unpack("a4a2a2")
      date.delete("")
      return "%s.register_date like ?", date.join("-") + '%', {:date => date}
    end
  end

  def add_wish
    if params[:id] == current_user.login
      require 'controllers/main'
      controller = Tmarker::Main.new({
        :func    => 'wish',
        :apikey  => User.find_by_login(params[:id]).apikey,
        :jancode => params[:jancode],
        :agent   => request.headers['User-Agent']
      })
      controller.exec ? redirect_to("/my/#{current_user.login}/wish") : error
    else
      error
    end
  end

  def delete_wish
    if params[:id] == current_user.login
      require 'controllers/main'
      controller = Tmarker::Delete.new({
        :func    => 'wish',
        :apikey  => User.find_by_login(params[:id]).apikey,
        :jancode => params[:jancode],
        :agent   => request.headers['User-Agent']
      })
      render :text => {:result => controller.exec, :id => params[:jancode]}.to_json
    else
      error
    end
  end

  def lock_item
    if params[:id] == current_user.login
      result = lock
      unless result.nil?
        render :text => {:result => true, :id => params[:jancode], :open => result}.to_json
      else
        render :text => {:result => false}.to_json
      end
    else
      error
    end
  end

  private

  def generate_condition(cond = nil, args = [], table_name = nil)
    conditions = []
    condition = "users.login = ?"
    condition+= " AND #{cond % table_name.pluralize}" unless cond.nil?
    conditions << condition
    conditions << params[:id]
    args.each do |arg| conditions << arg end
    conditions
  end

  def describe_menu(param = {})
    Mypage.current_user = current_user.login
    # head menu
    @categories = group(@page_name, {:conditions => generate_condition})
    @prices     = Mypage.price_list
    # side menu
    @profile        = Mypage.profile
    #@qrcode         = Mypage.qrcode({:size => 250, :charset => "UTF-8"})
    @category_count = Mypage.category_count(@page_name)
    @total_cost     = Mypage.total_costs
    @calendar       = Mypage.calendar(param[:date], @page_name)
  end

  def describe_common(param = {})
    # tab name
    @page_name = param[:page_name]
    # tab name save to session
    save_tab_session(@page_name)
    # title
    @title = application_title(param[:title], current_user.login)
  end

  def describe_index(param)
    # common
    describe_common(param)
    # menu
    describe_menu(param)
    # role
    @role = item_role
    # accesskey for feed
    @accesskey = @users.accesskey
    render :action => 'index'
  end

  def describe_wish(param)
    # common
    describe_common(param)
    # menu
    describe_menu(param)
    # role
    @role = wish_role
    # accesskey for feed
    @accesskey = @users.accesskey
    # action name
    @action = {:name => param[:page_name]}.to_json
    render :action => 'wish'
  end

  def describe_register(param)
    # common
    describe_common(param)
    # item count
    @item_count = param[:item_count]
    # register flg
    @non_register = param[:non_register]
    render :action => 'register'
  end

  def describe_download(param)
    # common
    describe_common(param)
    render :action => 'download'
  end

  def describe_blogparts(param)
    # common
    describe_common(param)
    render :action => 'blogparts'
  end
end
