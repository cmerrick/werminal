$(function(){

    $('#werminal').keydown(function(event){
		if (event.which == 13) {
			$.getJSON('/e',
					  {q: $(event.target).val()})
				.success(function(data){
					if(data.redirect) {
						location.href = data.redirect;
						return false;
					} else if (data.popup) {
						window.open(data.popup, '_blank');
						return false;
					} else if (data.stdout) {
						$('#output').html(JSON.stringify(data.stdout));
						return false;
					} else {
						alert('invalid response');
						return false;
					}
				})
				.error(function(data){
					$('#output').html(JSON.stringify(data));
				});
		}
    });
    
});
