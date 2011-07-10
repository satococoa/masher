# coding: utf-8

class Masher
  def self.convert_hex(str)
    an = []
    str.split(//).each do |s|
      an << format("%x",s.unpack("U*")[0])
    end
    an.join("").scan(/.../)
  end

  def self.convert_scale(str)
    no = 0
    str.split(//).each do |s|
      s_hex = format("%x",s.unpack("U*")[0]).to_i
      no += s_hex
    end
    no
  end
end

enable :sessions
configure do
  TITLE = 'Masher*'
end
configure :development do
  REDIS = Redis.new
end
configure :production do
  uri   = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  def get_tweets(hashtag)
    key = hashtag.to_sym
    if session[:key].nil? 
      search = Twitter::Search.new.hashtag(hashtag).no_retweets.per_page(50).fetch
    else
      search = Twitter::Search.new.hashtag(hashtag).no_retweets.since_id(session[:key]).per_page(50).fetch
    end
    session[:key] = search.first.id if search.size > 1
    search
  end
  def transform(tweets)
    tweets.map do |i|
      {
        :id => i.id,
        :user => i.from_user,
        :icon => i.profile_image_url,
        :text => i.text,
        :colors => Masher::convert_hex(i.text)
      }
    end
  end
end

get '/styles.css' do
  scss :styles
end

get '/script.js' do
  coffee :script
end

get '/:hashtag' do |hashtag|
  pass if hash.blank?
  haml :screen, :locals => {:class_name => 'screen', :hashtag => hashtag}
end

get '/tweets/:hashtag' do |hashtag|
  pass if hash.blank?
  tweets = get_tweets(hashtag)
  data = transform(tweets)
  data.to_json
end

get '/' do
  haml :index, :locals => {:class_name => 'index'}
end

post '/' do
  rm_hash = params[:hashtag].gsub!(/#?/,"")
  redirect "/#{rm_hash}"
end
  
