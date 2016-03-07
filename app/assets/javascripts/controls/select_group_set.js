window.on_pageload = window.on_pageload || [];
window.on_pageload.push(function() {
  'use strict';
  var elems = document.querySelectorAll('div.select-group-set');
  for (var i = 0; i < elems.length; i++) {
    var elem = elems[i];
    var parentControlId = elem.getAttribute('data-parent');
    var children = elem.querySelectorAll('div.select-group');
    var parentControls = document.querySelectorAll('input[name="' + parentControlId + '"]');
    for (var j = 0; j < parentControls.length; j++) {
      parentControls[j].addEventListener('change', function(event) {
        for (var x = 0; x < children.length; x++) {
          var isCurrent = event.target.value === children[x].getAttribute('data-key');
          var isHidden = children[x].classList.contains('hidden');
          if (isHidden && isCurrent) {
            children[x].classList.remove('hidden');
          } else if (!(isHidden || isCurrent)) {
            children[x].classList.add('hidden');
          }
        }
      });
    }
  }
});