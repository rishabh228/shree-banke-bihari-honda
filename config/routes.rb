# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "public/home#index"

  namespace :public, path: "", as: "" do
    resources :bikes, only: [ :index, :show ], param: :slug
    resources :offers, only: [ :index ]
    resources :accessories, only: [ :index ]
    get "finance", to: "finance#index"
    get "insurance", to: "insurance#index"
    resources :test_rides, only: [ :new, :create ]
    resources :service_bookings, only: [ :new, :create ]
    resources :enquiries, only: [ :new, :create ]
    get "about", to: "pages#about"
    get "contact", to: "pages#contact"
    get "privacy", to: "pages#privacy"
    get "terms", to: "pages#terms"
    post "contact", to: "enquiries#create"
  end

  namespace :admin do
    root "dashboard#index"

    resources :bikes do
      member do
        patch :publish
        patch :hide
      end
    end
    resources :offers
    resources :accessories
    resources :test_rides, only: [ :index, :show, :edit, :update, :destroy ] do
      member do
        patch :transition
      end
    end
    resources :service_bookings, only: [ :index, :show, :edit, :update, :destroy ] do
      member do
        patch :assign
        patch :transition
      end
    end
    resources :enquiries, only: [ :index, :show, :edit, :update, :destroy ]
    resources :pages
    resources :banners
    resources :media_assets
    resource :settings, only: [ :show, :edit, :update ]
    resources :users
    get "reports", to: "reports#index"
  end
end
