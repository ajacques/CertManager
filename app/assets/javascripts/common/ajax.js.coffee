GetCsrfToken = () -> document.querySelector('meta[name="csrf-token"]').content

this.Ajax =
  post:(url, opts) ->
    return new Promise((resolve, reject) ->
      request = new XMLHttpRequest()
      request.open('POST', url, true)
      request.setRequestHeader('Content-Type', opts.contentType)
      request.setRequestHeader('X-CSRF-Token', GetCsrfToken())
      request.onload = () ->
        if (request.status == 200)
          resolve.call(request.responseText)
        else
          reject.call(request.responseText)
      request.send(JSON.stringify(opts.data))
    )
  get:(url, opts) ->
    params = Object.keys(opts.data).map((key) -> encodeURIComponent(key) + '=' + encodeURIComponent(opts.data[key]))
    return new Promise((resolve, reject) ->
      request = new XMLHttpRequest()
      request.open('GET', url + '?' + params, true)
      request.setRequestHeader('Accept', opts.acceptType)
      request.onload = () ->
        body = request.responseText
        if opts.acceptType == 'application/json'
          body = JSON.parse(body)
        if request.status == 200
          resolve(body)
        else
          reject(body)
      request.send(JSON.stringify(opts.data))
    )
