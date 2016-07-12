var AsyncTask = (function() {
  'use strict';
  var handle_loop = function(url_func, promise) {
    return function(result) {
      if (result.status === 'unfinished') {
        window.setTimeout(function() {
          $.ajax({
            url: url_func({wait_handle: result.wait_handle}),
            method: 'GET'
          }).success(handle_loop(url_func, promise));
        }, 500);
        return;
      }

      promise.resolve(result);
    };
  };

  return {
    start: function(data) {
      var promise = $.Deferred();
      Ajax.post(data.url(), {
        acceptType: 'application/json',
        contentType: 'application/json',
        data: data.data
      }).then(handle_loop(data.url, promise));

      return promise;
    }
  };
})();
