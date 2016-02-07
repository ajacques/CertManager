var AsyncTask = (function() {

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
      $.ajax({
          url: data.url(),
          dataType: 'json',
          method: 'POST',
          data: data.data
      }).then(handle_loop(data.url, promise));

      return promise;
    }
  };
})();
