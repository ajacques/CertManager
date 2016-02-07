(function(root) {
  'use strict';
  root.SubjectAltNameList = React.createClass({
    render: function() {
      return (<input name="certificate[csr_attributes][subject_alternate_names][]" type="text" className="san-textbox form-control" />);
    }
  });
})(this);