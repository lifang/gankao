// JavaScript Document
//tab**************
 jQuery(function() {
	 jQuery('.mokao_left > div').bind('click',function(){
	   		jQuery(this).addClass('mkl_h').siblings().removeClass('mkl_h');
			var index = jQuery('.mokao_left > div').index(this);alert(index);
			jQuery('.mokao_right > .mk_r_div').eq(index).show().siblings().hide();alert(3);
	});
 })
	