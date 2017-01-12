Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'
  resources :results
  resources :test_instances
  resources :test_runs
  resources :test_cases
  resources :test_suites
  resources :tables
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
