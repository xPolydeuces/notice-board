require "sidekiq/web"

Rails.application.routes.draw do
  # Authenticated admin tools - must come before other routes
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web, at: "/sidekiq"
    mount PgHero::Engine, at: "/pghero"
  end

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
    resources :rss_feeds do
      member do
        post :refresh
        get :preview
      end
    end
    resource :password, only: %i[edit update]
  end
end
