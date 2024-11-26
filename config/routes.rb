Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  scope '/cognito' do
    post :create_role, to: 'cognito#create_role'
    post :add_user_to_group, to: 'cognito#add_user_to_group'
    post :remove_user_from_group, to: 'cognito#remove_user_from_group'
    # post :add_role_permission, to: 'cognito#add_role_permission'
    # post :update_role_permission, to: 'cognito#update_role_permission'
  end
end
