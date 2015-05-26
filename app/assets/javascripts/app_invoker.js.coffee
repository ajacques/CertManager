document.addEventListener 'DOMContentLoaded', () ->
  page_name = document.body.getAttribute('data-page')
  page_obj = window[page_name]
  for d, i in on_pageload
    d()
  if "function" == typeof page_obj
    page_obj()