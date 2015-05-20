var CertificateNew = new function() {
  var self = this;
  var subject_root;
  var subject_boxes = [];
  var addTextbox = function() {
    var elem = document.createElement('input');
    subject_root.appendChild(elem);
  };
  var handleSubjectKey = function(evt) {
    if (this.value !== "" && subject_boxes.length == 1) {
                                              addTextbox();
    }
  };
  var attachEventHandlers = function() {
    subject_boxes[0].addEventListener('keypress', handleSubjectKey);
  };

  self.init = function() {
    subject_root = document.getElementById('subjectAltList');
    subject_boxes.push(document.getElementById('subject[CN]'));
    attachEventHandlers();
  };
};