var CertificatesNew = function() {
  'use strict';
  var self = this;
  var subject_root = document.getElementById('subjectAltList');
  var subject_boxes = [];
  subject_boxes.push(document.getElementById('certificate_csr_attributes_subject_alternate_names'));
  var add_textbox = function() {
    var elem = document.createElement('input');
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