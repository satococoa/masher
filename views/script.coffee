$ ->
  if $('#screen').length > 0
    interval = 3000
    fetch = () ->
      if $('#hashtag').val() isnt ''
        $.getJSON '/tweets/'+$('#hashtag').val(), (data, status) ->
          console.log data
      else
        console.log 'noting'

    # timer
    fetcher = setInterval () ->
      fetch()
    , interval

    # initial get
    fetch()

