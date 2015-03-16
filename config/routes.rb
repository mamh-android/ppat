Rails.application.routes.draw do
resources :record_lists
post "record_lists/delete"
post "record_lists/create_by_task"
resources :carts
get "ondemand/index"
get "ondemand/get_task_detail"
get "ondemand/get_dc"
get "ondemand/get_task"
get "daily/index"
get "daily/query"
get "daily/get_comment"
get "daily/get_verify"
get "daily/show_dc"
get "daily/update_comments"
get "daily/show_chart_by_tab"
get "home/index"
get "home/update_calendar"
get "home/get_platform_detail"
get "home/get_code_drop"
get "compare/index"
post "compare/add_daily_compare"
post "/compare/add_ondemand_compare"
get "compare/get_compare_detail"
get "compare/get_dc"
get "baremetal/index"
get "trigger/index"
post "trigger/trigger"
post "trigger/upload"
get "trigger/get_device"
get "trigger/update_testcase"
get "query/index"
get "query/delete_job"
get "query/update_queue"
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



  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
