Rails.application.routes.draw do
  root to: 'visitors#index'
  post '/add' => 'visitors#add'
  get '/finder' => 'visitors#finder'
  post '/find' => 'visitors#find'
end
