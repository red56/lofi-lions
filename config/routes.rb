Rails.application.routes.draw do

  devise_for :users

  resources :languages

  resources :localized_texts do
    member do
      get "flow/:flow", action: :flow, as: :flow
    end
  end

  resources :master_texts, except: [:index, :new]

  resources :projects do
    resources :master_texts, only: [:index, :new]
    resources :views, only: [:index, :new]
  end

  resources :project_languages, only: [:index, :show, :update] do
    member do
      get :next
    end
    resources :texts, controller: "localized_texts" do
      collection do
        get :entry
        get :review
      end
    end
    resources :views, controller: "localized_views"
  end

  resources :users

  resources :views, except: [:index, :new]

  namespace :api, defaults: {format: "json"} do
    resources :projects, only: [] do
      member do
        post "import/(:platform)", action: "import"
        post "languages/:code/import/(:platform)", action: "import"
        get "export/:platform/:code", action: "export"
      end
    end
  end

  root "welcome#index"

  get "docs", to: "welcome#docs", as: "docs"
end
