class IndexController < ViewController
  helper :index, :feed

  def top
    index
  end

  def category
    index({:conditions => ["groups.product_name = ? AND items.open = ?",
      params[:name], true]})
  end

  private

  def index(cond = {:conditions => ["items.open = ?", true]})
    # title
    @title = application_title
    # main
    @items = item(cond)
    # head menu
    @groups = group('item')
    # side menu
    @development_log = development_log(5)
    @tracking_log = tracking_log(5)
    render :action => 'index'
  end
end
