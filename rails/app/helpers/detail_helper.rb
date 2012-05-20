module DetailHelper
  def set_detail_item_data(item)
    @item = item
  end

  def item_image
    link_to(
      image_tag(@items.item_image_medium || @items.item_image_small || m('item_no_image_large')),
      image_url(:jancode => item_jancode)
    )
  end

  def item_image_large
    image_tag(@item.item_image_large || m('item_no_image_large'))
  end

  def generate_detail_title
    unless current_user.nil?
      item_title + generate_user_count + generate_wish
    else
      item_title + generate_user_count
    end
  end

  def generate_detail_publisher
    item_publisher
  end

  def generate_detail_release_date
    item_release_date
  end

  def generate_detail_price
    item_price
  end

  def generate_detail_jancode
    item_jancode
  end

  def generate_recommendation
    @recommendations.nil? ? recommendation_notfound : recommendation_list
  end

  def generate_reference_user
    "<div class='reference_users'>%s%s</div>" % [generate_reference_user_title, reference_user_list]
  end

  def generate_reference_user_title
    "<p class='heart'>#{m('message_detail_reference_user')}</p>"
  end

  def generate_wish
    @wish ? "<input type='hidden' name='jancode' value='#{@item.jancode}'/>" +
      image_submit_tag(m('icon_wish'), :class => 'add_wish') : ""
  end

  def recommendation_list
    html = "<ul>"
    @recommendations.each do |e|
      set_detail_item_data(e)
      html += "<li>#{recommendation_thumbnail}</li>"
    end
    html += "</ul>"
  end

  def recommendation_notfound
    m('message_no_recommendation')
  end

  def recommendation_thumbnail
    link_to(image_tag(@item.item_image_small || m('item_no_image'), :alt => @item.item_title), @item.item_link)
  end

  def reference_user_list
    html = "<ul>"
    @users.each do |e|
      html += "<li>%s</li>" % e.user.login
    end
    html += "</ul>"
  end
end
