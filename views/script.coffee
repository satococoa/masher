$ ->
  if $('#screen').length > 0
    hashtag = $('#hashtag').val()
    interval = 5000
    fetch = () ->
      if hashtag isnt ''
        $.getJSON '/tweets/'+hashtag, (data, status) ->
          if localStorage[hashtag]
            tweets = JSON.parse(localStorage[hashtag])
          else
            tweets = {}
          for d in data
            tweets[d.id] = d
          localStorage[hashtag] = JSON.stringify(tweets)

    process = (tweet) ->
      console.log tweet

    # timer
    fetcher = setInterval () ->
      fetch()
    , interval

    # initial get
    fetch()

