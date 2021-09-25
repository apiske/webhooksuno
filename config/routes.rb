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
    resources :binding_requests

    post 'publish', to: 'publisher#publish'

    # Receiver API

    resources :subscriptions

    get 'bindings/:code/check', to: 'bindings#check'
    post 'bindings/:code/activate', to: 'bindings#activate'
    get 'bindings/:binding_id/topics', to: 'bindings#index_topics'
  end
end
