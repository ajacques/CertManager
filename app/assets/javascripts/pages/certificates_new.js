var CertificatesNew = function() {
  'use strict';
  var self = this;
  var subject_root = document.getElementById('subject-alt-list');

  var san = ReactDOM.render(React.createElement(SubjectAltNameList, {}), subject_root);
};
