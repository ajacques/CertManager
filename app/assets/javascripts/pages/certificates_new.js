var CertificatesNew = function() {
  'use strict';
  var self = this;
  var subject_root = document.getElementById('subject-alt-list');
  var boxCount = 0;
  var usedBoxes = 0;

  var san_box_tmpl = document.getElementById('subject-alt-name-body').innerHTML;
  Mustache.parse(san_box_tmpl);

  var add_textbox;

  var handle_change = function(evt) {
    var newName = '';
    var delta = -1;
    if (this.value !== '') {
      newName = this.getAttribute('data-name');
      delta = 1;
    }
    if (this.name !== newName) {
      this.name = newName;
      usedBoxes += delta;

      if (delta > 0) {
        add_textbox();
      }
    }
  };
  add_textbox = function() {
    var elem = document.createElement('div');
    elem.innerHTML = Mustache.render(san_box_tmpl);
    var textbox = elem.getElementsByClassName('san-textbox')[0];
    textbox.addEventListener('keyup', handle_change);
    subject_root.appendChild(elem);
    boxCount++;
  };

  add_textbox();
  var attach = document.getElementById('multi-keyword-box');
  React.render(React.createElement(SubjectAltBox, {}), attach);
};
