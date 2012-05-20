module MyconfigHelper
  def generate_myconfig_page(page_in_action)
    select_tag_name, page = page_in_action.keys[0].to_s, page_in_action.values[0].to_s
    "<span>#{m('message_myconfig_page')}</span>" +
      select_tag(select_tag_name, options_for_select(m('mypage_paginate').gsub(/\s/, '').split(/,/), page))
  end

  # TODO できれば共通化したい
  def generate_myconfig_sidebar_list_by_item
    html = []
    @side_menu_in_item.each do |e|
      e.each do |menu_name, bool|
        menu_name_with_identifier = convert_role_key_by_item(menu_name)
        html << "<li><div class='myconfig_frame'>%s%s%s</div></li>" %
          [generate_myconfig_frame_header(menu_name), generate_myconfig_form(menu_name_with_identifier, bool), generate_myconfig_thumbnail(menu_name)]
      end
    end
    html
  end

  def generate_myconfig_sidebar_list_by_wish
    html = []
    @side_menu_in_wish.each do |e|
      e.each do |menu_name, bool|
        menu_name_with_identifier = convert_role_key_by_wish(menu_name)
        html << "<li><div class='myconfig_frame'>%s%s%s</div></li>" %
          [generate_myconfig_frame_header(menu_name), generate_myconfig_form(menu_name_with_identifier, bool), generate_myconfig_thumbnail(menu_name)]
      end
    end
    html
  end

  def generate_myconfig_frame_header(menu_name)
    header_name = "message_side_#{menu_name}"
    "<div class='myconfig_frame_header'>%s</div>" % m(header_name)
  end

  def generate_myconfig_form(name, checked)
    "<div class='myconfig_form'>%s%s</div>" % [generate_myconfig_check(name, checked), generate_myconfig_label(name)]
  end

  def generate_myconfig_label(name)
    "<label for=#{name}>%s<label>" % m('message_myconfig_checkbox_label')
  end

  def generate_myconfig_check(name, checked)
    check_box_tag(name, 1, checked)
  end

  def generate_myconfig_thumbnail(menu_name)
    config_name = "myconfig_#{menu_name}_image"
    "<div class='myconfig_thumbnail'>%s</div>" % image_tag(m(config_name))
  end

  def convert_role_key_by_item(role_key)
    convert_role("item", role_key)
  end

  def convert_role_key_by_wish(role_key)
    convert_role("wish", role_key)
  end

  def convert_role(prefix, key)
    "#{key}_in_#{prefix}"
  end
end
