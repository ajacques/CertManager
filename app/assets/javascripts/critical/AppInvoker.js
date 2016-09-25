(function() {
  var page_inst;

  window.on_pageload = window.on_pageload || [];

  function initializeReact() {
    var className, clazz, element, j, len, props, ref, results;
    ref = document.querySelectorAll('div[data-react-mount=true]');
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      element = ref[j];
      className = element.getAttribute('data-react-class');
      clazz = window[name] || window[className];
      props = JSON.parse(element.getAttribute('data-react-props'));
      results.push(ReactDOM.render(React.createElement(clazz, props), element));
    }
    return results;
  }

  const PageInitializer = function() {
    var d, i, j, len, page_name, page_obj, ref;
    ref = window.on_pageload;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      d = ref[i];
      d();
    }
    window.on_pageload = {
      push: function(item) {
        return item();
      }
    };
    page_name = document.body.getAttribute('data-page');
    page_obj = window[page_name];
    if ("function" === typeof page_obj) {
      page_obj();
    } else if ("object" === typeof page_obj) {
      page_obj.init();
    }
    return initializeReact();
  };

  if (document.readyState === "complete" || document.readyState === "loaded") {
    page_inst = PageInitializer();
  } else {
    document.addEventListener('DOMContentLoaded', PageInitializer);
  }
}).call(this);
