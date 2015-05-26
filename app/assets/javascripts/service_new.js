var ServiceNew = new function() {
  var self = this;
  var refresh_nodes = function(evt) {
    $.ajax({
      url: location.origin + '/services/nodes?query=' + this.value,
      dataType: 'json',
      success: function(data) {
        var list = $('ul#node_list');
        list.html('');
        for (var i = 0; i < data.length; i++) {
          var elem = document.createElement('li');
          elem.innerHTML = data[i];
          list.append(elem);
        }
      }
    });
  };

  self.init = function() {
    var target_nodes = document.getElementById('node_group');
    target_nodes.addEventListener('keyup', refresh_nodes);
  };
};