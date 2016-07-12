var SettingsShow = function() {
  function handleValidateResponse(data) {

  }

  function handleValidateRecord(event) {
    event.preventDefault();
    var validate_target = event.target.getAttribute('data-settings-validate');
    var path_functor = Routes['validate_' + validate_target + '_settings_path'];
    Ajax.post(path_functor()).then(handleValidateResponse);
  }

  this.init = function() {
    var items = document.querySelectorAll('button[data-settings-validate]');
    for (var i = 0; i < items.length; i++) {
      items[i].addEventListener('click', handleValidateRecord);
    }
  };

  this.init();
};