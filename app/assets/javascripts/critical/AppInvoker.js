(function() {
  window.on_pageload = window.on_pageload || [];

  function initializeReact() {
    var className, clazz, element, j, len, props, ref, results;
    ref = document.querySelectorAll('[data-react-mount=true]');
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
    var i, j, len, page_obj, ref;
    ref = window.on_pageload;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      ref[i]();
    }
    window.on_pageload = {
      push: function(item) {
        item();
      }
    };
    var page_name = document.body.getAttribute('data-page');
    page_obj = window[page_name];
    if (typeof page_obj === "function") {
      page_obj();
    } else if (typeof page_obj === "object") {
      page_obj.init();
    }
    initializeReact();
  };

  if (document.readyState === "complete" || document.readyState === "loaded") {
    PageInitializer();
  } else {
    document.addEventListener('DOMContentLoaded', PageInitializer);
  }
}).call(this);
