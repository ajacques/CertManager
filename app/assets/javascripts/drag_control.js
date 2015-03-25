var on_pageload = on_pageload || [];
on_pageload.push(function() {
  var supported_mimes = ["application/x-x509-ca-cert", "text/plain", "application/x-pem-file"];
  var capture_drop = function(event) {
    event.dataTransfer.effectAllowed = "copyMove";
    event.dataTransfer.dropEffect = "copy";
    return false;
  };
  var finish_drop = function(event) {
    var target = document.getElementById('key');
    for (var i = 0; i < supported_mimes.length; i++) {
      var data = event.dataTransfer.getData(supported_mimes[i]);
      if (data !== "") {
        target.textContent += target;
        return false;
      }
    };
    if (event.dataTransfer.files.length >= 1) {
      var reader = new FileReader();
      reader.onload = function(text) {
        target.textContent += text.target.result;
      };
      for (var i = 0; i < event.dataTransfer.files.length; i++) {
        reader.readAsText(event.dataTransfer.files[i]);
      };
    }
    return false;
  };
  var targets = document.getElementsByClassName('drop-target');
  for (var i = 0; i < targets.length; i++) {
    targets[i].ondragover = capture_drop;
    targets[i].ondrop = finish_drop;
  };
});