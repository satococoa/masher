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
  def get_tweets(hashtag)
    Twitter::Search.new.hashtag(hashtag).no_retweets.per_page(5).fetch
  end
  def transform(tweets)
    tweets.map {|i| {:text => i.text, :color => ['#fff', '#000']} }
  end
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

get '/tweets/:hashtag' do |hashtag|
  pass if hash.blank?
  tweets = get_tweets(hashtag)
  data = transform(tweets)
  data.to_json
end
