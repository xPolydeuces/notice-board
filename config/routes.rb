require "sidekiq/web"

Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes (skip registration - admins create users)
  devise_for :users, skip: [:registrations], controllers: {
    sessions: "users/sessions"
  }

  # Public display (notice board)
  root "dashboard#index"

  # Admin namespace
  namespace :admin do
    root "dashboard#index"

    resources :users do
      member do
        post :reset_password
      end
    end
    resources :locations
    resources :news_posts do
      member do
        patch :archive
        patch :restore
        patch :publish
        patch :unpublish
      end
    end
    resources :rss_feeds
    resource :password, only: [:edit, :update]
  end

  # Authenticated admin tools
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web, at: "sidekiq"
    mount PgHero::Engine, at: "pghero"
  end
end