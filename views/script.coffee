$ ->
  if $('.screen').length > 0
    loaded = 0
    hashtag = $('#hashtag').val()
    fetch_interval   = 30000
    process_interval = 5000
    shown = {}

    fetch = () ->
      if hashtag isnt ''
        $.getJSON '/tweets/'+hashtag, (data, status) ->
          if sessionStorage[hashtag]
            tweets = JSON.parse(sessionStorage[hashtag])
          else
            tweets = []
          for d in data
            if not shown[d.id]
              tweets.push d
              shown[d.id] = 1
          sessionStorage[hashtag] = JSON.stringify(tweets)

    process = (num) ->
      if sessionStorage[hashtag]
        tweets = JSON.parse(sessionStorage[hashtag])
        for i in [0...num]
          tweet = tweets.shift()
          if tweet
            sessionStorage[hashtag] = JSON.stringify(tweets)
            set_colors tweet.colors
            set_tweet tweet
            loaded++
            article = $("article:nth-child(#{loaded})")
            if article.length > 0
              article.removeClass('loading')
              

    set_colors = (colors) ->
      i = 0
      $('.color').css('background-color', '#fff')
      for color in colors
        $(".color:nth-child(#{i})").css('background-color', "##{color}")
        i++

    copy_content = (from, to) ->
      to.html(from.html())
      to.css('background-color', from.css('background-color'))

    set_tweet = (tweet) ->
      # console.log tweet.timestamp+' : '+tweet.user+' : '+tweet.text
      first  = $('article:first')
      second = $('article:nth-child(2)')
      third  = $('article:nth-child(3)')
      forth  = $('article:nth-child(4)')
      fifth  = $('article:last')
      copy_content(forth, fifth)
      copy_content(third, forth)
      copy_content(second, third)
      copy_content(first, second)

      first.find('.icon img').attr('src', tweet.icon)
      first.find('h2').text(tweet.user)
      tagstr = "#"+hashtag
      re = new RegExp('('+tagstr+')', 'i')
      first.find('.tweet p').html(tweet.text.replace(re, '<span class="hashtag">$1</span>'))
      if tweet.include_important
        first.css('background-color', '#663333');
      else
        first.css('background-color', '#000000');

    # timer
    fetcher = setInterval () ->
      fetch()
    , fetch_interval

    processer = setInterval () ->
      process(1)
    , process_interval

    # initialize
    sessionStorage.clear()
    fetch()
