SuncorpNpsApp::Application.routes.draw do

  resources :search_suggestions


  get "feedback/new"
  get "feedback/create"

  match "/settings" => "settings#index"
  match "/settings/swap" => "settings#swapWidget"
  match "/settings/blist" => "settings#gblistIndex", :as => :gblist
  match "/settings/blist/add" => "settings#gblistAdd", :as => :gb_add
  match "/settings/blist/remove" => "settings#gblistRemove", :as => :gb_remove
  match "/settings/blist/addcsv" => "settings#gblistAddCsv", :as => :gb_addcsv

  resources :teams
  match 'teams/:id/updateTeam' => "teams#changeRole"
  match 'teams/:id/addMember' => "teams#addMember", :as => :team_add_member
  match 'teams/:id/deleteMember' => "teams#deleteMember"
  
  devise_scope :user do
    devise_for :users, :controllers => {:registrations => "users/registrations"}
    get "/", :to => "devise/sessions#new"
    get "/profile" => "users/registrations#edit", :as => :profile
  end
  
  resources :services
  
   match 'services/:id' => 'services#show'
   match 'services/:id/report' => 'services#report', :as => :service_report  
   match 'services/:id/reportSubmit' => 'services#reportSubmit'
   match '/services' => "services#index", as: :user_root
   match 'services/:id/report_pdf' => 'services#print', :as => :service_print 

  resources :surveys

   match 'services/:id/survey' => 'surveys#index', :as => :surveyindex
   match 'services/:id/survey/add' => 'surveys#addEmail', :as => :add
   match 'services/:id/survey/remove' => 'surveys#removeEmail', :as => :add
   match 'services/:id/survey/upload' => 'surveys#upload', :as => :surveys_upload
   match 'services/:id/survey/sendEmail' => 'surveys#sendEmail', :as => :send_email
   match 'survey' => 'surveys#survey', :as => :survey
   match 'thankyou' => 'surveys#submitSurvey'
   match 'services/:id/survey/blacklist' => 'surveys#blacklist'
   match 'services/:id/survey/dlistremove' => 'surveys#dlistRemove'
   match 'services/:id/survey/dlistadd' => 'surveys#dlistAdd', :as => :d_add
   match 'services/:id/survey/dlistaddcsv' => 'surveys#dlistAddCsv', :as => :dlistAddCsv
   match 'services/:id/survey/blistremove' => 'surveys#blistRemove'
   match 'services/:id/survey/blistadd' => 'surveys#blistAdd', :as => :b_add
   match 'services/:id/survey/blistaddcsv' => 'surveys#blistAddCsv', :as => :blistAddCsv
   match 'services/:id/emaillists' => 'surveys#emailListIndex', :as => :emaillists
   
  resources :feedback 
   match 'feedback/new' => 'feedback#mail', :as => :mail

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

  root :to => "devise/sessions#new"
  match '*path' => redirect('/')

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
