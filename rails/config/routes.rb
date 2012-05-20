ActionController::Routing::Routes.draw do |map|
  map.resources :users

  map.resource :session

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

  # top page
  map.toppage            '/', :controller => 'index', :action => 'top'
  map.toppage_category   '/category/:name', :controller => 'index', :action => 'category'

  # shared
  map.development_log    '/log/development', :controller => 'log', :action => 'development'
  map.tracking_log       '/log/tracking', :controller => 'log', :action => 'tracking'

  # mypage(index)
  map.mypage             '/my/:id', :controller => 'mypage', :action => 'item'
  map.mypage_category    '/my/:id/category/:name', :controller => 'mypage', :action => 'item_by_category'
  map.mypage_price       '/my/:id/price/l/:low_price', :controller => 'mypage', :action => 'item_by_price'
  map.mypage_price       '/my/:id/price/h/:high_price', :controller => 'mypage', :action => 'item_by_price'
  map.mypage_price       '/my/:id/price/l/:low_price/h/:high_price', :controller => 'mypage', :action => 'item_by_price'
  map.mypage_calendar    '/my/:id/date/:date', :controller => 'mypage', :action => 'item_by_calendar'

  # mypage(wish)
  map.mypage_wish        '/my/:id/wish', :controller => 'mypage', :action => 'wish'
  map.mypage_category    '/my/:id/wish/category/:name', :controller => 'mypage', :action => 'wish_by_category'
  map.mypage_price       '/my/:id/wish/price/l/:low_price', :controller => 'mypage', :action => 'wish_by_price'
  map.mypage_price       '/my/:id/wish/price/h/:high_price', :controller => 'mypage', :action => 'wish_by_price'
  map.mypage_price       '/my/:id/wish/price/l/:low_price/h/:high_price', :controller => 'mypage', :action => 'wish_by_price'
  map.mypage_calendar    '/my/:id/wish/date/:date', :controller => 'mypage', :action => 'wish_by_calendar'
  map.mypage_add_wish    '/my/:id/add_wish', :controller => 'mypage', :action => 'add_wish'
  map.mypage_delete_wish '/my/:id/delete_wish', :controller => 'mypage', :action => 'delete_wish'
  map.mypage_lock_item   '/my/:id/lock_item', :controller => 'mypage', :action => 'lock_item'
  map.mypage_qrcode      '/my/:id/qrcode', :controller => 'mypage', :action => 'qrcode'

  # mypage(register)
  map.mypage_register    '/my/:id/register', :controller => 'mypage', :action => 'register'

  # mypage(download)
  map.mypage_download    '/my/:id/download', :controller => 'mypage', :action => 'download'
  map.mypage_gm          '/my/:id/download/gm/:file', :controller => 'mypage', :action => 'download_gm', :file => /tmarker\.user\.js/
  map.mypage_addon       '/my/:id/download/addon/:file', :controller => 'mypage', :action => 'download_addon', :file => /tmarker-(.*)\.xpi/

  # mypage(blogparts)
  map.mypage_blogparts   '/my/:id/blogparts', :controller => 'mypage', :action => 'blogparts'

  # myconfig
  map.myconfig           '/conf/:id', :controller => 'myconfig', :action => 'read'
  map.myconfig_save      '/conf/:action/:id', :controller => 'myconfig', :action => 'save'

  # detail page
  map.detail             '/detail/:jancode', :controller => 'detail', :action => 'detail'
  map.image              '/image/:jancode', :controller => 'detail', :action => 'image'

  # restful authentication routing
  map.signup             '/signup', :controller => 'users', :action => 'new'
  map.login              '/login',  :controller => 'sessions', :action => 'new'
  map.logout             '/logout', :controller => 'sessions', :action => 'destroy'

  # rss/atom
  map.feed               '/feed.:format', :controller => 'feed', :action => 'public_feed'
  map.myfeed             '/:accesskey/:func/feed.:format', :controller => 'feed', :action => 'private_feed'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
