LofiLions::Application.routes.draw do
  devise_for :users

  resources :languages do |language|
    resources :texts, controller: 'localized_texts' do
      collection do
        get :entry
        get :review
      end
    end
  end

  resources :master_texts

  resources :users
  
  post 'import/:action', controller: 'import', defaults: { format: 'html' }

  root 'welcome#index'

end
