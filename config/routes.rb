Rails.application.routes.draw do
  root to: 'visitors#index'
  post '/add' => 'visitors#add'
  get '/add' => 'visitors#add_user'
  get '/finder' => 'visitors#finder'
  get '/audit' => 'visitors#audit'
  post '/find' => 'visitors#find'
  post '/reset' => 'visitors#reset'
end
