# coding: utf-8

configure :development do
  config = YAML::load_file('config.yml')
end

configure :production do
  SOME_VALUE = ENV['SOME_VAUE']
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/styles.css' do
  scss :styles
end

get '/script.js' do
  coffee :script
end

get '/' do
  haml :index
end
