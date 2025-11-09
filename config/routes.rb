Rails.application.routes.draw do
  # devise_for :users  # Disabled for portfolio
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Account page - Disabled for portfolio
  # resource :account, only: [ :show ]

  # Public pages
  root "pages#landing"
  get "about", to: "pages#about", as: "about"
  # get "pricing", to: "pages#pricing", as: "pricing"  # Disabled for portfolio
  get "contact", to: "pages#contact", as: "contact"
  # get "privacy", to: "pages#privacy", as: "privacy"  # Optional - uncomment if needed
  # get "terms", to: "pages#terms_of_service", as: "terms"  # Optional - uncomment if needed

  # Contact
  resources :contact_messages, only: [ :create ]

  # Pay - Disabled for portfolio
  # post "checkout", to: "checkouts#create", as: "checkout"
  # get "checkout/success", to: "checkouts#success", as: "checkout_success"
  # get "checkout/cancel", to: "checkouts#cancel", as: "checkout_cancel"
  # post "billing_portal", to: "billing_portal#create", as: "billing_portal"
end
