Gankao::Application.routes.draw do
  match '/signout'=> 'sessions#destroy'
  namespace :rater do
    resources :exam_raters do
      collection do
        get "session","check_paper"
      end
      member do
        post "edit_value"
        get "rater_session","get_score"
        post "rater_login","over_answer"
        get "reader_papers","answer_paper"
      end
    end
  end
    resources :payments do
    member do
      get :payoff
    end
    collection do
       get :packed_payoff,"agency_recharge"
       post "search_account"
    end
  end
  resources :sessions do
    collection do
      get "get_code"
      post "user_code"
    end
    member do
      get "new_code","active"
      post "update_user_code"
    end
  end
  resources :users do
    collection do
      get "get_proof_code", "get_register_code", "re_active", "active_success", "active_false"
    end
    member do
      get "active", "user_active"
      post "update_info"
    end
  end
   namespace :user do
    resources :examinations do
      member do
        post "save_result", "five_min_save"
        get "do_exam"
      end
      collection do
        get "error_page"
      end
    end
    resources :exam_users do
      collection do
        get "session_new", "affiremed_false","affiremed_success"
        post "exam_session","search"
        get "search_list"
      end
      member do
        get "my_results"
         get "exam_user_affiremed"
        post "edit_score","edit_name"
      end
    end
   end
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
  # root :to => "welcome#index"
  root :to => "sessions#new"
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
