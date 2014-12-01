require 'rubygems'
require 'sinatra'

set :sessions, true

get '/some_text' do
  "Some text!"
end

# template
get '/nested' do
  erb :'users/template_file'
end


get '/form' do
  erb :form
end

post '/myaction' do
  "Hello #{params[:your_name]}!"
end

