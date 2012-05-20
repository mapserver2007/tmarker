module MypageHelper
  def set_search_item_data(item)
    @item = item
  end

  # header menu
  def header_mypage_category_list(image_name, label, page_name)
    action_name = "#{page_name}_by_category"
    user_id = current_user.login rescue nil
    category_url = url_for(:action => action_name, :id => user_id, :name => label).gsub(/\?.*/, '')
    header_category_list(image_name, label, category_url)
  end

  # tab name
  def generate_tab
    tab = m('mypage_tab')
    html = ""
    blank_td = "<td><div class='space'>&nbsp;</div></td>"
    tab_td   = "<td class='%s'><h3>%s</h3></td>"
    tab.each do |e|
      tab_id, tab_name = e["tab_id"], e["tab_name"]
      html += blank_td
      tab_state = nil
      url = url_for(:controller => 'mypage', :action => tab_id, :id => current_user.login)
      if tab_id == @page_name
        tab_state = 'tab_open'
      else
        tab_state = 'tab_close'
        tab_name  = link_to(tab_name, url)
      end
      html += tab_td % [tab_state, tab_name]
    end
    html += "<td width='100%'><div class='space'>&nbsp;</div></td>"
  end

  # main menu
  def generate_mypage_item_list(idx)
    set_item_data(idx)
    class_name = "item_frame #{@item.open ? "item_open" : "item_close"}"
    "<li><div id='#{@item.jancode}' class='#{class_name}'>%s%s%s%s</div></li>" %
      [generate_item_frame_header, generate_item_register_info, generate_image_with_count, generate_item_description]
  end

  def generate_mypage_wish_list(idx)
    set_item_data(idx)
    "<li><div id='#{@item.jancode}' class='item_frame'>%s%s%s%s</div></li>" %
      [generate_wish_frame_header, generate_item_register_info, generate_image, generate_item_description]
  end

  def blogparts_site_error
    unless @result[:message].nil?
      message = "「#{@result[:allow_url]}」#{@result[:message]}"
      "<div class='blogparts_error'>#{message}</div>"
    end
  end

  # side menu
  def category_to_json
    category_data = []
    @categories.each do |category|
      category_data << {:id => category[:group_id],
        :name => category.group[:product_name]}
    end
    user_data = {:id => current_user.login}
    {:category => category_data, :user => user_data}.to_json
  end

  def price_to_json
    user_data = {:id => current_user.login}
    {:price => @prices, :user => user_data}.to_json
  end

  def side_category_count(c)
    image_tag(c[:product_icon], :alt => c[:product_group]) + c.count
  end

  def side_calendar(calendar)
    html, td, reg_day = [], "", []
    t = calendar[:month]
    ymd = Time.now.strftime("%Y%m%d")
    calendar[:reg].each do |e|
      reg_day << e.date.split(/-/)[2].to_i
    end
    calendar[:cal].each_with_index do |e, i|
      _td = "<td"
      today = nil
      unless(e == "")
        _td << " class='%s"
        day_of_the_week_list = %w[sunday monday tuesday wednesday thursday friday satuaday]
        y, m, d = t.strftime("%Y"), t.strftime("%m"), sprintf("%02d", e)
        today, day_of_the_week_idx = y + m + d, Time.local(y, m, d).to_a[6]
        _td %= day_of_the_week_list[day_of_the_week_idx]
        _td << (ymd == today ? " today'>%s</td>" : "'>%s</td>")
      else
       _td << "></td>"
      end
      e = link_to_date(e, today) if reg_day.include?(e)
      td << _td % e
      if (i % 7 == 6)
        html << "<tr>#{td}</tr>"
        td = ""
      end
    end
    html << "<tr>#{td}</tr>"
    html.join("\n")
  end

  def side_slide_date(calendar)
    t = calendar[:month]
    months = []
    [t.last_month, t, t.next_month].each_with_index do |e, i|
      current_label = nil
      current_date = e.to_a[5].to_s + sprintf("%02d", e.to_a[4])
      case i
        when 0
          current_label = image_tag('arrow_l.png', :alt => 'last month', :border => '0')
        when 1
          current_label = "#{e.to_a[5].to_s}年#{sprintf('%02d', e.to_a[4])}月"
        when
          current_label = image_tag('arrow_r.png', :alt => 'next month', :border => '0')
      end
      months << link_to_date(current_label, current_date)
    end
    html  = "<span class='cal_last'>#{months[0]}</span>"
    html << "<span>#{months[1]}</span>"
    html << "<span class='cal_next'>#{months[2]}</span>"
    html
  end

  def link_to_date(label, date)
    action_name = "#{@page_name}_by_calendar"
    calendar_url = url_for(:action => action_name, :id => current_user.login, :date => date)
    link_to(label, calendar_url)
  end

  def search_by_jancode(item)
    "<div>#{search_item(item)}</div>"
  end

  def search_item(item)
    if item.length == 0
      m('message_no_search')
    else
      set_search_item_data(item)
      html = "<div class='register_search_image'>"
      html += link_to(image_tag(@item[:item_image_medium]), @item[:item_link]) ||
        link_to(image_tag(@item[:item_image_small]), @item[:item_link]) || m('item_no_image_large')
      html += "</div>"
      html += "<div class='register_search_description'>"
      html += search_item_description
      html += "</div>"
      html += "<div class='clearfix'></div>"
      html
    end
  end

  def search_item_description
    html = "<h2>#{search_item_title}</h2>"
    html += "<p>#{search_item_publisher}</p>"
    html += "<p>#{search_item_price}</p>"
    html += "<p>#{search_item_release_date}</p>"
  end

  def generate_wish
     @non_register ? "<input type='hidden' name='jancode' value='#{@items[:jancode]}'/>" +
        image_submit_tag(m('icon_wish'), :class => 'add_wish') : ""
  end

  def search_item_title
    link_to(@item[:item_title], @item[:item_link]) + generate_user_count + generate_wish
  end

  def search_item_publisher
    publisher = [@item[:author], @item[:creator], @item[:publisher]].each_with_object [] do |e, res|
      res << e unless e.nil?
    end
    publisher.length == 0 ? m('message_no_publisher') : publisher.join('/')
  end

  def search_item_price
    @item[:item_price].nil? ? m('message_no_price') :
      number_to_currency(@item[:item_price], :precision => 0, :format => "%n%u", :unit => "円")
  end

  def search_item_release_date
    (@item[:release_date] || @item[:publication_date]).strftime("%Y年%m月")
      rescue m('message_no_release_date')
  end

end
