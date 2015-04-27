document.addEventListener('DOMContentLoaded', function() {
	'use strict'
	var elems = document.getElementsByClassName('cert-body');
	var selectAll = function(evt) {
		this.focus();
		this.select();
	};
	for (var i = 0; i < elems.length; i++) {
		elems[i].addEventListener('click', selectAll);
	}
	Turbolinks.enableProgressBar();
});