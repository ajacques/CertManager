var AsyncTask = (function() {
  'use strict';
  var handle_loop = function(url_func, resolve, reject) {
    return function(result) {
      if (result.status === 'unfinished') {
        window.setTimeout(function() {
          Ajax.get(url_func({wait_handle: result.wait_handle})).success(handle_loop(url_func, resolve, reject));
        }, 500);
        return;
      }

      resolve(result);
    };
  };

  return {
    start: function(data) {
      return new Promise(function(resolve, reject) {
        Ajax.post(data.url(), {
          acceptType: 'application/json',
          contentType: 'application/json',
          data: data.data
        }).then(handle_loop(data.url, resolve, reject));
      });
    }
  };
})();
