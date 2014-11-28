# myapp.rb 
require 'sinatra'
# NEW COMMENT!


# get '/' do 
#   'Hello World'
# end


get '/foo.html' do
  "Hello #{params[:name]}!!!!"
end

get '/hello/:name' do
  "Hello #{params[:name]}!"
end