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
      collection do
        get :export_pdf
      end
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
      collection do
        get :export_pdf
      end
      member do
        patch :assign
        patch :transition
      end
    end
    resources :enquiries, only: [ :index, :show, :edit, :update, :destroy ] do
      collection do
        get :export_pdf
      end
      member do
        post :convert_to_sale
      end
    end
    resources :sales do
      collection do
        get :export_pdf
      end
      member do
        patch :transition
        get :quotation_pdf
      end
    end
    resources :pages
    resources :banners
    resources :media_assets
    resource :settings, only: [ :show, :edit, :update ]
    resource :contact_page, only: [ :edit, :update ], controller: "contact_pages"
    resources :users
    resources :notifications, only: [ :index ] do
      member do
        patch :mark_read
      end
      collection do
        patch :mark_all_read
      end
    end
    get "reports", to: "reports#index"
  end
end
