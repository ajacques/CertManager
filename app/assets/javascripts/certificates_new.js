var CertificatesNew = function() {
  'use strict';
  var self = this;
  var subject_root = document.getElementById('subject-alt-list');
  var subject_boxes = subject_root.children;
  var san_box_tmpl = document.getElementById('subject-alt-name-body').innerHTML;
  Mustache.parse(san_box_tmpl);
  var add_textbox = function() {
    var elem = document.createElement('div');
    elem.innerHTML = Mustache.render(san_box_tmpl);
    subject_root.appendChild(elem);
  };
  var handle_subject_key = function(evt) {
    if (this.value !== "" && subject_boxes.length == 1) {
      add_textbox();
    }
  };
  var attach_event_handlers = function() {
    subject_boxes[0].addEventListener('keypress', handle_subject_key);
  };

  attach_event_handlers();
};