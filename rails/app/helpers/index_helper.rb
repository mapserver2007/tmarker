module IndexHelper
  # header menu
  def header_index_category_list(image_name, label)
    header_category_list(image_name, label)
  end

  # main menu
  def generate_index_item_list(idx)
    set_item_data(idx)
    "<li><div id='#{@item.jancode}' class='item_frame'>%s%s%s%s</div></li>" %
      [generate_item_frame_header, generate_item_register_info, generate_image, generate_item_description]
  end
end
