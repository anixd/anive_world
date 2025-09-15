Rails.application.routes.draw do
  get "/login", to: "auth#new", as: :login
  post "/auth", to: "auth#create", as: :auth
  delete "/logout", to: "auth#destroy", as: :logout

  get "previews/:type/:slug", to: "previews#show", as: :preview

  forge_routes = -> do
    root "dashboard#index", as: :dashboard

    resources :languages do
      resources :parts_of_speech
      resources :roots
      resources :affixes
    end
    resources :roots
    resources :affixes
    resources :translations, only: [:index, :show]

    resources :lexemes do
      get :parts_of_speech, on: :collection
      resources :words, only: [:new, :create]
    end

    resources :words, only: [:show, :edit, :update, :destroy]

    resources :articles
    resources :history_entries
    resources :characters
    resources :locations
    resources :grammar_rules
    resources :phonology_articles

    namespace :timeline do
      resources :calendars
      resources :eras
    end

    resources :notes
  end

  namespace :forge, &forge_routes

  scope path: "/f", module: "forge", as: :f, &forge_routes # alias `/f`

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "auth#new"
  # for future use
  # root "public/home#index"
end
