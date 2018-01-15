(function() {
  window.on_pageload = window.on_pageload || [];

  function initializeReact() {
    var ref = document.querySelectorAll('[data-react-mount=true]');
    for (var j = 0, len = ref.length; j < len; j++) {
      var element = ref[j];
      var className = element.getAttribute('data-react-class');
      var props = JSON.parse(element.getAttribute('data-react-props'));
      window.App.HydrateComponent(className, props, element);
    }
  }

  function initializePage() {
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
  }

  if (document.readyState === "complete" || document.readyState === "loaded") {
    initializePage();
  } else {
    document.addEventListener('DOMContentLoaded', initializePage);
  }
}).call(this);
