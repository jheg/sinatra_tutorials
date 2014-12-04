# myapp.rb 
require 'sinatra'
# NEW COMMENT!


# get '/' do 
#   'Hello World'
# end


# get '/foo.html' do
#   "Hello #{params[:name]}!!!!"
# end

# get '/hello/:name' do
#   "Hello #{params[:name]}!"
# end

# set(:probability) {|value| condition { rand <= value } }

# get '/win_a_car', :probability => 0.1 do 
#   "You won!"
# end

# get '/win_a_car' do
#   "You did NOT win"
# end

class Stream
  def each
    10.times do |i| 
      yield "#{i}\n hi!!!!!!" 
    end
  end
end

get('/') { Stream.new }

