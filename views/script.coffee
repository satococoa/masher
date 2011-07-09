$ ->
  interval = 30000
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

