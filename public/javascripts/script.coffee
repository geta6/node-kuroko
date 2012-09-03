$ ->
  ($ '#channel').focus()
  ($ '#join').on 'click', () ->
    ch = ($ '#channel').val()
    if ch
      $.ajax
        url: "/join/#{ch}"
        type: 'POST'
        error: (xhr, status) =>
          alert 'AJAXエラーですの！'
          console.error status, xhr
        success: (data) =>
          alert 'これからjoinするので、しばらくお待ちくださいですの'
          ($ '#channel').val ''
    else
      alert 'channelが空ですの'
      ($ '#channel').focus()