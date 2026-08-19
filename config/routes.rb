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
    get "faq", to: "pages#show", defaults: { slug: "faq" }, as: :faq
    get "gallery", to: "gallery#index"
    get "pages/:slug", to: "pages#show", as: :cms_page
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
    resources :accessories do
      member do
        post :bill_on_counter
      end
    end
    resources :test_rides, only: [ :index, :show, :edit, :update, :destroy ] do
      member do
        patch :transition
        post :convert_to_enquiry
        post :convert_to_sale
      end
    end
    resources :service_bookings, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
      collection do
        get :export_pdf
      end
      member do
        patch :assign
        patch :transition
        patch :update_job_card
        get :job_card_pdf
        post :issue_workshop_invoice
        get :workshop_invoice_pdf
      end
      resources :job_card_lines, only: %i[create destroy]
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
        post :issue_invoice
        post :cancel_invoice
        get :invoice_pdf
        get :credit_note_pdf
        patch :allot_chassis
        get :delivery_challan_pdf
        get :form21_pdf
        get :form22_pdf
        get :gate_pass_pdf
        patch :capture_irn
      end
      resources :sale_add_ons, only: %i[create destroy]
      resources :payment_receipts, only: %i[create destroy] do
        member do
          get :pdf
        end
      end
    end
    resources :counter_invoices do
      member do
        post :issue
        get :invoice_pdf
        patch :capture_irn
        post :cancel_invoice
        get :credit_note_pdf
      end
      resources :lines, only: %i[create destroy], controller: "counter_invoice_lines"
    end
    resources :vehicle_units
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
        get :unread_count
      end
    end
    get "reports", to: "reports#index"
    get "reports/tally_export", to: "reports#tally_export", as: :reports_tally_export
  end
end
