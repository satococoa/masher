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
  ## REDISからツイートを取得するメソッド
  def get_tweets(hashtag)
    # 最後にそのハッシュタグのツイートを取得したのが30秒以上前だった場合、
    # 新しくツイートを取得してREDISに保存
    got_timestamp = REDIS.get("timestamp:#{hashtag}")
    if got_timestamp.to_i + 30 < Time.now.to_i
      get_tweets_from_api(hashtag)
    end
    # REDISのインデックス0から9を取得
    # 最新10件分が古い発言を先頭の要素として取得される
    # [発言1, 発言2, 発言3, ..., 発言10]
    tweets = REDIS.lrange("tweets:#{hashtag}", 0, 9)
    if tweets.nil?
      return []
    end
    tweets = tweets.map {|tweet| Hashie::Mash.new(JSON.parse(tweet)) }
    tweets = tweets.delete_if {|tweet| tweet.id <= session[hashtag].to_i }
    session[hashtag] = tweets.last.id.to_s if tweets.length > 0
    tweets
  end
  ## Twitter APIからツイートを取得、REDISにストアするメソッド
  def get_tweets_from_api(hashtag)
    # ハッシュタグ検索、RT除外して10件取得
    search = Twitter::Search.new.hashtag(hashtag).no_retweets.per_page(10)
    # ハッシュタグで検索された結果がREDISに保存されている場合、
    # 最新のツイートのIDがlast_idとしてREDISに保存されている
    # last_idがなければ最新10件をすべて取得、あればlast_id以降から取得（10件未満のこともあり）
    since_id = REDIS.get("last_id:#{hashtag}")
    if since_id.nil?
      tweets = search.fetch
    else
      tweets = search.since_id(since_id).fetch
    end
    if tweets.size > 0
      # 検索結果があれば、REDISにキー登録 timestampと最新のid
      REDIS.set "timestamp:#{hashtag}", Time.now.to_i
      REDIS.set "last_id:#{hashtag}", tweets.first.id
      # 最新10件を保持
      # APIから取得されたツイートは新しいものから順に最大10件
      # [発言10, 発言9, 発言8, ..., 発言1]
      tweets.reverse.each do |tweet|
        # ツイートの配列を反転させて古いツイートから順にREDISの末尾にjsonで追加
        # [発言1, 発言2, 発言3, ..., 発言10]
        # 元々発言(発言-2から発言0)がREDISに保存されていた場合は以下のようになる
        # [発言-2, 発言-1, 発言0, 発言1, 発言2, ..., 発言10]
        REDIS.rpush "tweets:#{hashtag}", tweet.to_json
      end
      # 右から数えて10件のみを残す
      # 最新10件が古いツイートを先頭として保存されている
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

