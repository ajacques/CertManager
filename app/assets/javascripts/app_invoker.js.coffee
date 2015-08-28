func = () ->
  window.on_pageload = window.on_pageload || []
  page_name = document.body.getAttribute('data-page')
  page_obj = window[page_name]
  for d, i in window.on_pageload
    d()
  if "function" == typeof page_obj
    console.info "Invoking registered page load handler"
    page_obj()
document.addEventListener 'DOMContentLoaded', func
if document.readyState == "complete" || document.readyState == "loaded" || document.readyState == "interactive"
  func()