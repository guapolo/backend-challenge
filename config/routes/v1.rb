# frozen_string_literal: true

scope :api do
  namespace :v1 do
    post :authenticate, controller: :authentication, action: :create

    resources :friendships, only: [:create]
    resources :members

    post :paths_to_experts_search, controller: :paths_to_experts, action: :search
  end
end
