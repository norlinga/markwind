require 'sinatra'

get '/' do
  @random = rand(1..999_000)
  erb :index
end