func = () ->
  page_name = document.body.getAttribute('data-page')
  page_obj = window[page_name]
  for d, i in on_pageload
    d()
  if "function" == typeof page_obj
    console.info "Registering page load handler"
    page_obj()
document.addEventListener 'DOMContentLoaded', func
if document.readyState == "complete" || document.readyState == "loaded" || document.readyState == "interactive"
  func()