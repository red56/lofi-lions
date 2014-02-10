LofiLions::Application.routes.draw do
  resources :languages do |language|
    resources :texts, controller: 'localized_texts' do
      collection do
        get :entry
        get :review
      end
    end
  end

  resources :master_texts

  root 'welcome#index'

end
