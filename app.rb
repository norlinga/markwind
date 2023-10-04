require 'sinatra'
require 'securerandom'

get '/' do
  @random = SecureRandom::uuid
  erb :index
end