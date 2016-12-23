window.on_pageload = window.on_pageload || [];
window.on_pageload.push(function() {
  function updateClasses(target, child) {
    var isCurrent = target === child.getAttribute('data-key');
    var isHidden = child.classList.contains('hidden');
    if (isHidden && isCurrent) {
      child.classList.remove('hidden');
    } else if (!(isHidden || isCurrent)) {
      child.classList.add('hidden');
    }
  }
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
          updateClasses(event.target.name, children[x]);
        }
      });
    }
  }
});
