function debounce(func, wait, immediate, maxWait) {
  var timeout;
  var maxWait = maxWait || 30 * 1000;
  var lastTrigger = null;
  return function() {
    var now = new Date();
    var context = this;
    var args = arguments;
    if (lastTrigger !== null && now - lastTrigger > maxWait) {
      func.apply(context, args);
      lastTrigger = new Date();
    }
    clearTimeout(timeout);
    timeout = setTimeout(function() {
      timeout = null;
      if (!immediate) {
        func.apply(context, args);
        lastTrigger = new Date();
      }
    }, wait);
    if (immediate && !timeout) {
      func.apply(context, args);
      lastTrigger = new Date();
    }
  };
}

function escapeHtml(html) {
  return String(html)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

var resolved_promise = function (result) {
  var deferred = $.Deferred();

  deferred.resolve(result);
  return deferred.promise();
};