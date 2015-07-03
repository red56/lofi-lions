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

  scope path: 'projects/:id',defaults: {format: 'html'} do
    post 'import/(:platform)', controller: 'import', action: 'import'
    post 'languages/:code/import/(:platform)', controller: 'import', action: 'import'
    get 'export/:action/:language', controller: 'exports'
  end

  root 'welcome#index'

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end
end
