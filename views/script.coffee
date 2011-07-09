$ ->
  if $('.screen').length > 0
    loaded = 0
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

    process = (num) ->
      if localStorage[hashtag]
        tweets = JSON.parse(localStorage[hashtag])
        for i in [0..num]
          tweet = tweets.shift()
          if localStorage[hashtag+'log']
            logs = JSON.parse(localStorage[hashtag+'log'])
          else
            logs = []
          logs.push(tweet)
          localStorage[hashtag+'log'] = JSON.stringify(logs)
          if tweet
            localStorage[hashtag] = JSON.stringify(tweets)
            # console.log "#{tweet.user} : #{tweet.id} : #{tweet.text} : #{tweet.icon}"
            set_colors tweet.colors
            set_tweet tweet
            loaded++
            article = $("article:nth-child(#{loaded})")
            if article.length > 0
              article.removeClass('loading')
              

    set_colors = (colors) ->
      i = 0
      for color in colors
        $(".color:nth-child(#{i})").css('background-color', "##{color}")
        i++

    set_tweet = (tweet) ->
      first  = $('article:first')
      second = $('article:nth-child(2)')
      third  = $('article:nth-child(3)')
      forth  = $('article:nth-child(4)')
      fifth  = $('article:last')
      fifth.html(forth.html())
      forth.html(third.html())
      third.html(second.html())
      second.html(first.html())
      first.find('.icon img').attr('src', tweet.icon)
      first.find('h2').text(tweet.user)
      tagstr = "#"+hashtag
      re = new RegExp('('+tagstr+')', 'i')
      first.find('.tweet p').html(tweet.text.replace(re, '<span class="hashtag">$1</span>'))

    # timer
    fetcher = setInterval () ->
      fetch()
    , fetch_interval

    processer = setInterval () ->
      process(1)
    , process_interval

    # initialize
    if localStorage[hashtag+'log']
      if localStorage[hashtag]
        tweets = JSON.parse(localStorage[hashtag])
      else
        tweets = []
      logs = JSON.parse(localStorage[hashtag+'log'])
      for log in logs
        tweets.push log
      localStorage[hashtag] = JSON.stringify(tweets)
    process(5)
    fetch()

