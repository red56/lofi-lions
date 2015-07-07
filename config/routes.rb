LofiLions::Application.routes.draw do

  devise_for :users

  resources :languages

  resources :master_texts, except: [:index, :new]

  resources :projects do
    resources :master_texts, only: [:index, :new]
  end

  resources :project_languages, only: [:index, :show, :update] do
    resources :texts, controller: 'localized_texts' do
      collection do
        get :entry
        get :review
      end
    end
    resources :views, controller: 'localized_views'
  end

  resources :users

  resources :views

  namespace :api, defaults: {format: 'json'} do
    resources :projects, only: [] do
      member do
        post 'import/(:platform)', action: 'import'
        post 'languages/:code/import/(:platform)', action: 'import'
        get 'export/:platform/:code', action: 'export'
      end
    end
  end

  root 'welcome#index'

  get 'docs', to: 'welcome#docs', as: 'docs'

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end
end
