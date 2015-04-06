var CertificateShow = function() {
	var self = this;
	var checkCRLStatus = function() {
		var crl_group = $('#crl-group');
		$.ajax({
			url: location.href + '/revocation_check.json',
			dataType: 'json',
			success: function(data) {
				var list = $('ul#crl-list');
				for (var i = 0; i < data.length; i++) {
					$('li[data-id="' + i + '"]').html(data[i]);
				};
			}
		});
	};

	self.init = function() {
	};
};