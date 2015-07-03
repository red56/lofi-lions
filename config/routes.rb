LofiLions::Application.routes.draw do
  resources :views

  devise_for :users

  resources :languages do |language|
    resources :texts, controller: 'localized_texts' do
      collection do
        get :entry
        get :review
      end
    end
    resources :views, controller: 'localized_views'
  end

  resources :master_texts

  resources :users

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

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end
end
