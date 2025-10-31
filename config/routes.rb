require "sidekiq/web"

Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes
  devise_for :users, skip: [:registrations], controllers: {
    sessions: "devise/sessions"
  }

  # Locale scope for internationalization
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    # Public display (notice board)
    root "dashboard#index"

    # Admin namespace
    namespace :admin do
      root "dashboard#index"
      
      resources :users
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
  end

  # Authenticated admin tools
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web, at: "sidekiq"
    mount PgHero::Engine, at: "pghero"
  end
end
