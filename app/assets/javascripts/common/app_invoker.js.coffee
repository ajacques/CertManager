window.on_pageload = window.on_pageload || []
initializeReact = () ->
  for element in document.querySelectorAll('div[data-react-mount=true]')
    className = element.getAttribute('data-react-class')
    clazz = window[name] || window[className]
    props = JSON.parse(element.getAttribute('data-react-props'))
    ReactDOM.render(React.createElement(clazz, props), element)
func = () ->
  for d, i in window.on_pageload
    d()
  # Automatically call any late load handlers
  window.on_pageload = {
    push: (item) -> item()
  }
  page_name = document.body.getAttribute('data-page')
  page_obj = window[page_name]
  if "function" == typeof page_obj
    page_obj()
  else if "object" == typeof page_obj
    page_obj.init()
  initializeReact()
if document.readyState == "complete" || document.readyState == "loaded"
  page_inst = func()
else
  document.addEventListener 'DOMContentLoaded', func