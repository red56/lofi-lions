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

  post 'projects/:id/import/:action', controller: 'import', defaults: { format: 'html' }
  get 'projects/:id/export/:action/:language', controller: 'exports'
  post 'projects/:id/languages/:code/import/:action', controller: 'import', defaults: { format: 'html' }

  root 'welcome#index'

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end
end
