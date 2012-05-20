class MyconfigController < ViewController
  helper :myconfig
  before_filter :session_validate, :title

  def save
    @side_menu = {
      :page_in_item           => params[:page_in_item],
      :profile_in_item        => !!params[:profile_in_item],
      :qrcode_in_item         => !!params[:qrcode_in_item],
      :category_count_in_item => !!params[:category_count_in_item],
      :total_cost_in_item     => !!params[:total_cost_in_item],
      :calendar_in_item       => !!params[:calendar_in_item],
      :page_in_wish           => params[:page_in_wish],
      :category_count_in_wish => !!params[:category_count_in_wish],
      :calendar_in_wish       => !!params[:calendar_in_wish]
    }
    user = User.find_by_login(params[:id])
    if user.update_attributes!(@side_menu)
      render :action => 'success'
    else
      error
    end
  end

  def read
    # side menu
    @side_menu_in_item = item_role
    @side_menu_in_wish = wish_role
    # page
    @page_in_item = {:page_in_item => current_user.page_in_item}
    @page_in_wish = {:page_in_wish => current_user.page_in_wish}

    render :action => 'index'
  end

  private

  def title
    @title = application_title('message_myconfig')
  end
end
