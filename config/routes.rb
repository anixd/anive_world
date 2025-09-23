Rails.application.routes.draw do
  get "/login", to: "auth#new", as: :login
  post "/auth", to: "auth#create", as: :auth
  delete "/logout", to: "auth#destroy", as: :logout

  get "previews/:type/:slug", to: "previews#show", as: :preview

  forge_routes = -> do
    root "dashboard#index", as: :dashboard

    get "search", to: "search#index"

    resources :tags do
      get :search, on: :collection
    end

    resources :tags do
      get :search, on: :collection
    end

    resources :languages do
      resources :parts_of_speech
      resources :roots
      resources :affixes
    end
    resources :translations, only: [:index, :show]

    resources :lexemes do
      get :parts_of_speech, on: :collection
      resources :words, only: [:new, :create]
    end

    resources :words, only: [:show, :edit, :update, :destroy] do
      get :search, on: :collection
    end

      resources :articles
    resources :history_entries
    resources :characters
    resources :locations
    resources :grammar_rules
    resources :phonology_articles
    resources :help_pages, path: "help"

    resource :export, only: [:show] do
      post :dictionary, on: :collection
      get :parts_of_speech, on: :collection
    end

    namespace :timeline do
      resources :calendars
      resources :eras
    end

    resources :notes
  end

  namespace :forge, &forge_routes

  scope path: "/f", module: "forge", as: :f, &forge_routes # alias `/f`


  # Public Area
  scope module: "pub", as: "pub" do
    get "search", to: "search#index"
    root "home#index"
    resources :articles, only: [:index, :show]
    resources :characters, only: [:index, :show]
    resources :locations, only: [:index, :show]
    resources :history_entries, only: [:index, :show], path: "history"
    resources :tags, only: [:show], param: :name
    resources :help_pages, path: "help", only: [:index, :show]
    resources :languages, only: [:index, :show] do
      resources :lexemes, only: [:index, :show], path: "dictionary"
      get "word-building", to: "word_building#index", as: :word_building
      get "grammar", to: "grammar#index", as: :grammar
      resources :roots, only: [:show]
      resources :affixes, only: [:show]
    end
    resources :grammar_rules, only: [:show], path: "grammar/rules"
    resources :phonology_articles, only: [:show], path: "phonology/articles"
  end

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
