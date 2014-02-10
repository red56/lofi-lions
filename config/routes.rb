LofiLions::Application.routes.draw do
  resources :languages do |language|
    resources :texts, controller: 'localized_texts'
  end

  resources :master_texts

  root 'welcome#index'

end
