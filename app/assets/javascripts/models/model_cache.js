(function() {
  'use strict';
  var root = this.ModelCache = {};
  var cache = {};

  root.get = function(group, id) {
    var key = group + '/' + id;
    if (cache.hasOwnProperty(key)) {
      return cache[key];
    }

    var val = new group({id: id});
    cache[key] = val;
    return val;
  };
}).call(this);
