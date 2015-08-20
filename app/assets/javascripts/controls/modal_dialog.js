var ModalDialog = function() {
  var body = document.body;
  var modal = document.getElementById('modal');
  var header = modal.getElementsByClassName('modal-title')[0];
  var modal_body = modal.getElementsByClassName('modal-body')[0];
  var close_buttons = modal.getElementsByClassName('close-button');

  var md = {
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

  md.close = function() {
    modal.classList.remove('center-block');
    body.classList.remove('modal-visible');
  };

  for (var i = 0; i < close_buttons.lengthg; i++) {
    close_buttons[i].addEventListener('click', md.close);
  }

  return md;
};