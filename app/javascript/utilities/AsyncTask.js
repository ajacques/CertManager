import Ajax from 'utilities/Ajax';

export default (function() {
  'use strict';
  function handleLoop(url_func, resolve, reject) {
    return function(result) {
      if (result.status === 'unfinished') {
        window.setTimeout(function() {
          Ajax.get(url_func({wait_handle: result.wait_handle}), {
            acceptType: 'application/json'
          }).then(handleLoop(url_func, resolve, reject));
        }, 500);
        return;
      }

      resolve(result);
    };
  }

  return {
    start: function(data) {
      return new Promise(function(resolve, reject) {
        Ajax.post(data.url(), {
          acceptType: 'application/json',
          contentType: 'application/json',
          data: data.data
        }).then(handleLoop(data.url, resolve, reject));
      });
    }
  };
})();
