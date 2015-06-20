var ModalDialog = function() {
  var body = document.body;
  var modal = document.getElementById('modal');
  var header = modal.getElementsByClassName('modal-title')[0];
  var modal_body = modal.getElementsByClassName('modal-body')[0];

  return {
    setHeader: function(text) {
      header.innerHTML = text;
    },
    setBody: function(text) {
      modal_body.innerHTML = text;
    },
    show: function(text) {
      body.classList.add('modal-visible');
      modal.classList.add('center-block');
    }
  };
};