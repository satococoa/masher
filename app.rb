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
    got_timestamp = REDIS.get("timestamp:#{hashtag}")
    if got_timestamp.to_i + 30 < Time.now.to_i
      get_tweets_from_api(hashtag)
    end
    tweets = REDIS.lrange("tweets:#{hashtag}", 0, 9)
    if tweets.nil?
      return []
    end
    tweets = tweets.map {|tweet| Hashie::Mash.new(JSON.parse(tweet)) }
    tweets = tweets.delete_if {|tweet| tweet.id <= session[hashtag].to_i }
    session[hashtag] = tweets.last.id.to_s if tweets.length > 0
    tweets
  end
  def get_tweets_from_api(hashtag)
    search = Twitter::Search.new.hashtag(hashtag).no_retweets.per_page(10)
    since_id = REDIS.get("last_id:#{hashtag}")
    if since_id.nil? 
      tweets = search.fetch
    else
      tweets = search.since_id(since_id).fetch
    end
    if tweets.size > 0
      REDIS.set "timestamp:#{hashtag}", Time.now.to_i
      REDIS.set "last_id:#{hashtag}", tweets.first.id
      # 最新10件を保持
      tweets.reverse.each do |tweet|
        REDIS.rpush "tweets:#{hashtag}", tweet.to_json
      end
      REDIS.ltrim "tweets:#{hashtag}", -10, -1
    end
  end
  def transform(tweets)
    tweets.map do |i|
      {
        :id => i.id,
        :user => i.from_user,
        :icon => i.profile_image_url,
        :text => i.text,
        :colors => Masher::convert_hex(i.text),
        :timestamp => i.created_at
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

get '/' do
  haml :index, :locals => {:class_name => 'index'}
end

post '/' do
  rm_hash = params[:hashtag].gsub!(/#?/,"")
  redirect "/#{rm_hash}"
end
  
get '/:hashtag' do |hashtag|
  session.clear
  haml :screen, :locals => {:class_name => 'screen', :hashtag => hashtag}
end

get '/tweets/:hashtag' do |hashtag|
  tweets = get_tweets(hashtag)
  data = transform(tweets)
  data.to_json
end

