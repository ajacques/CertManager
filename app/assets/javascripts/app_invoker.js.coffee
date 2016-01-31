window.on_pageload = window.on_pageload || []
func = () ->
  for d, i in window.on_pageload
    d()
  page_name = document.body.getAttribute('data-page')
  page_obj = window[page_name]
  console.info "Invoking registered page load handler"
  if "function" == typeof page_obj
    page_obj()
  else if "object" == typeof page_obj
    page_obj
if document.readyState == "complete" || document.readyState == "loaded"
  page_inst = func()
else
  document.addEventListener 'DOMContentLoaded', func