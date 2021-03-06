Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api_v1, path: '/v1', module: 'api_v1' do
    # Shared API

    resources :keys

    # Sender API

    resources :topics
    resources :routers
    resources :tags
    resources :webhook_definitions
    resources :receiver_bindings

    post 'publish', to: 'publisher#publish'

    # Receiver API

    resources :subscriptions

    resources :bindings do
      member do
        get :topics
      end
    end
  end

  # Admin API

  if Comff.get_bool!("admin.enabled")
    namespace :admin, path: '/admin', module: 'api_admin' do
      resources :workspaces do
        member do
          post :rotate_api_key
        end
      end
    end
  end
end
