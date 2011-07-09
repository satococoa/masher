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
  haml :screen, :locals => {:hashtag => hashtag}
end

get '/tweets/:hashtag' do |hashtag|
  pass if hash.blank?
  tweets = get_tweets(hashtag)
  data = transform(tweets)
  data.to_json
end

get '/' do
  haml :index
end

post '/' do
  redirect "/#{params[:hashtag]}"
end
  
