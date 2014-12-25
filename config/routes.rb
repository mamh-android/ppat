Ppat::Application.routes.draw do

  resources :record_lists
  post "record_lists/delete"
  post "record_lists/create_by_task"

  resources :carts

  get "ondemand/index"
  get "ondemand/get_task_detail"
  get "ondemand/get_dc"

  get "daily/index"

  get "daily/query"

  get "home/index"
  get "home/update_calendar"
  get "home/get_platform_detail"


  get "compare/index"
  post "compare/add_daily_compare"
  post "/compare/add_ondemand_compare"
  get "compare/get_compare_detail"
  get "baremetal/index"

  get "trigger/index"

  get "query/index"

  post "log/in"
  get "log/in"
  get "log/out"

  # other web pages from marvell
  get "tools/gerrit"
  get "tools/buildbot"
  get "tools/rtvb"
  get "tools/xref"
  get "tools/oldppat"
  get "tools/smoketest"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
