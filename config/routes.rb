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

  post 'import/:action', controller: 'import', defaults: { format: 'html' }
  get 'export/:action/:language', controller: 'exports'
  post 'languages/:id/import/:action', controller: 'languages_import', defaults: { format: 'html' }

  root 'welcome#index'

end
