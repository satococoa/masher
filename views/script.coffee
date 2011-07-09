$ ->
  if $('#screen').length > 0
    hashtag = $('#hashtag').val()
    fetch_interval   = 30000
    process_interval = 5000

    fetch = () ->
      if hashtag isnt ''
        $.getJSON '/tweets/'+hashtag, (data, status) ->
          if localStorage[hashtag]
            tweets = JSON.parse(localStorage[hashtag])
          else
            tweets = []
          for d in data
            tweets.push d
          localStorage[hashtag] = JSON.stringify(tweets)

    process = () ->
      if localStorage[hashtag]
        tweets = JSON.parse(localStorage[hashtag])
        tweet = tweets.shift()
        localStorage[hashtag] = JSON.stringify(tweets)
        # debug
        console.log "#{tweet.id} : #{tweet.text}"

    # timer
    fetcher = setInterval () ->
      fetch()
    , fetch_interval

    processer = setInterval () ->
      process()
    , process_interval

    # initialize
    process()
    fetch()

