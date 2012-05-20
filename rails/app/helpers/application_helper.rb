# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def m(key)
    Setting.read_config(key)
  end

  def paginate(data)
    will_paginate(data) if data.length > 0
  end

  def set_all_item_data
    @@items  = @items
    @@groups = @items.each_with_object [] do |e, group| group << e.group end
    @@users  = @items.each_with_object [] do |e, user| user << e.user end
  end

  def set_item_data(idx)
    @item = @@items[idx]
    @group = @@groups[idx]
    @user = @@users[idx]
  end

  def link(url, label)
    url.nil? ? label : link_to(label, url)
  end

  def logo
    link_to(image_tag(m('logo_image'), :id => 'logo', :alt => 'logo', :border => "0"), '/')
  end

  def login_state
    user_menu = []
    user_menu << m('message_welcome') % user
    user_menu << link_to_mypage if logged_in?
    user_menu << link_to_myconfig if logged_in?
    user_menu.join(' | ') + " | %s | %s" % [link_to_login, link_to_signup]
  end

  def user
    logged_in? ? current_user.login : m('message_default_username')
  end

  def link_to_login
    logged_in? ? link_to(m('message_logout'), logout_url) : link_to(m('message_login'), login_url)
  end

  def link_to_signup
    link_to(m('message_signup'), signup_url)
  end

  def link_to_mypage
    link_to(m('message_mypage'), '/my/' + current_user.login)
  end

  def link_to_myconfig
    link_to(m('message_myconfig'), myconfig_url(:id => current_user.login))
  end

  def cut(str, n)
    str.length > n ? str.slice(0, n) << "..." : str
  end

  def header_category_list(image_name, label, url = nil)
    url = toppage_category_url(:name => label) if url.nil?
    image_tag('/images/' + image_name) + link(url, label)
  end

  def generate_item_frame_header
    "<div class='item_frame_header'>#{generate_item_category}</div>"
  end

  def generate_wish_frame_header
    "<div class='item_frame_header'>#{generate_wish_category}</div>"
  end

  def generate_item_register_info
    "<div class='item_register_info'><p>#{@item.register_date.strftime("%Y/%m/%d")}</p><p>#{@user.login}</p></div>"
  end

  def generate_image
    item_thumbnail = "<div class='item_thumbnail_frame'>%s%s%s</div>" %
      [generate_item_thumbnail, generate_item_zoom, generate_item_detail]
    "<div class='item_image'>%s%s</div>" % [item_thumbnail, generate_item_barcode]
  end

  def generate_image_with_count
    item_thumbnail = "<div class='item_thumbnail_frame'>%s%s%s%s</div>" %
      [generate_item_thumbnail, generate_item_zoom, generate_item_count, generate_item_detail]
    "<div class='item_image'>%s%s</div>" % [item_thumbnail, generate_item_barcode]
  end

  def generate_item_thumbnail
    link_to(image_tag(@item.item_image_small || m('item_no_image'), :alt => @item.item_title, :class => 'item_thumbnail'), @item.item_link)
  end

  def generate_item_zoom
    link_to(image_tag(m('icon_zoom'), :class => 'zoom_thumbnail'), image_url(:jancode => @item.jancode))
  end

  def generate_item_count
    items = @item.item_count == 1 ? "item" : "items"
    "<div class='item_count'>#{@item.item_count}#{items}</div>"
  end

  def generate_item_delete
    image_tag(m('icon_delete'), :class => 'delete_thumbnail')
  end

  def generate_item_barcode
    "<div class='item_barcode #{item_jancode}'></div>"
  end

  def generate_item_description
    html = "<div class='item_description'>"
    html+= "<p>#{item_title(100)}</p>"
    html+= "<div>#{[item_publisher(50), item_price, item_release_date].join(' | ')}</div>"
    html+= "</div>"
  end

  def generate_category
    user_id = current_user.login rescue nil
    action_name = @page_name.nil? ? "category" : "#{@page_name}_by_category"
    category_url = url_for(:action => action_name, :id => user_id, :name => @group.product_name).gsub(/\?.*/, '')
    {
      :image => image_tag('/images/' + @group.product_icon, :alt => @group.product_group),
      :link  => link_to(@group.product_name, category_url)
    }
  end

  def generate_item_category
    data = generate_category
    if !data.nil? && !params[:id].nil?
      data[:request] = {:user_id => current_user.login, :jancode => @item.jancode}.to_json
      data[:lock] = "<input type='image' src='" + (@item.open ? m('icon_unlock') : m('icon_lock')) +
        "' onclick='mypage.lock_item(#{data[:request]});'/>"
      "<div class='item_cateogry'>%s%s%s</div>" % [data[:image], data[:link], data[:lock]]
    else
      "<div class='item_cateogry'>%s%s</div>" % [data[:image], data[:link]]
    end
  end

  def generate_wish_category
    data = generate_category
    if !data.nil?
      data[:request] = {:user_id => current_user.login, :jancode => @item.jancode}.to_json
      data[:delete]  = "<input type='image' src='" + m('icon_delete') + "' onclick='mypage.delete_wish(#{data[:request]});'/>"
      "<div class='item_cateogry'>%s%s%s</div>" % [data[:image], data[:link], data[:delete]]
    end
  end

  def generate_item_detail
    "<div class='item_detail'>#{link_to(m('message_detail'), url_for(:controller => 'detail', :action => 'detail', :jancode => @item.jancode))}</div>"
  end

  def generate_user_count
    html = ""
    if @item_count != 0
      users = @item_count == 1 ? "user" : "users"
      html = "<span class='users'>#{@item_count}#{users}</span>"
    end
    html
  end

  def item_title(n = nil)
    if @item.item_title.nil?
      m('message_no_title')
    else
      title = n.nil? ? @item.item_title : cut(@item.item_title, n)
      @item.item_link.nil? ? title : link_to(title, @item.item_link)
    end
  end

  def item_publisher(n = nil)
    publisher = [@item.author, @item.creator, @item.publisher].each_with_object [] do |e, res|
      unless e.nil?
        res << (!n.nil? && e.length > n ? cut(e, n) : e)
      end
    end
    publisher.length == 0 ? m('message_no_publisher') : publisher.join('/')
  end

  def item_price
    @item.item_price.nil? ? m('message_no_price') :
      number_to_currency(@item.item_price, :precision => 0, :format => "%n%u", :unit => "円")
  end

  def item_release_date
    (@item.release_date || @item.publication_date).strftime("%Y年%m月") rescue m('message_no_release_date')
  end

  def item_jancode
    @item.jancode
  end

  def item_list_notfound
    m('message_no_item')
  end

  def category_list_notfound
    m('message_no_category')
  end
end