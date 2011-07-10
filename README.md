# [Masher](http://masher.heroku.com)　〜マッシャー〜

twitterのハッシュタグを表示するイベント用出力ツールです。


## FEATURE

* イベント会場などでスライドや大型モニターに表示するために特化しています
* 字は大きめで、同時表示数は最大5件
* ハッシュタグに色が付きます
* ツイートの内容をRGB分解したカラーバー
* Ruby / Sinatra製


## USAGE

* [トップページ](http://masher.heroku.com)でハッシュタグを入力
* しばらくすると検索結果が自動的にロードされます


## DEVELOPMENT

* ローカルで動かすにはRedisが必要です。
* $ brew install redis


## TODO

* 特定のキーワードによって色つけ(例.質問, 空調, トイレなど)
* CSSアニメーション
* テスト


## WHY MAKE THIS

* 2011-07-09 Sat. に行われたハッカソンで一日でつくれるサービスとして制作されました
* Member

  * [@satococoa](https://twitter.com/#!/satococoa)
  * [@milligramme](https://twitter.com/#!/milligramme)
  * [@machida](https://twitter.com/#!/machida)
  * [@9d](https://twitter.com/#!/9d)
