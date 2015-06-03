Rails.application.routes.draw do
  resources :messages
  resources :users
  
  resources :session
  
  get '/two_factor' => "session#two_factor"
  get '/verify' => "session#verify"
  post '/verify' => "session#verify"
  
  get 'logout' => 'session#destroy', as: :logout
  get 'login' => 'session#new', as: :login
  get 'signup' => 'users#new', as: :signup
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get "verify_mobile" => "users#verify_mobile"
  get "mobile_verification" => "users#mobile_verification"
  post "mobile_verification" => "users#mobile_verification"
  get "final_verification" => "users#final_verification"
  post "final_verification" => "users#final_verification"
  post "make_call" => "users#make_call"
  post "create_call" => "users#create_call"
  post 'connect' => 'users#connect'
  post 'process_gather' => 'users#process_gather'
  get "connect_twilio" => "users#connect_twilio"
  post "authorize" => "users#authorize"
  
  get "input" => "users#input"
  post "input" => "users#input"
  get "initial_listen" => "users#initial_listen"   
  post "initial_listen" => "users#initial_listen"
  post "employess" => "users#employees"
  get "employees" => "users#employees"
  post "make_an_ivr" => "users#make_an_ivr"
  post "handle_ivr_call" => "users#handle_ivr_call" 
  get "twilio_client" => "users#twilio_client"
  get "handle_twilio_client" => "users#handle_twilio_client"
  post "handle_twilio_client" => "users#handle_twilio_client"
  post "client_incoming_call" => "users#client_incoming_call"
  get "bulk_sms" => "users#bulk_sms"
  # You can have the root of your site routed with "root"
   root 'users#index'
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
