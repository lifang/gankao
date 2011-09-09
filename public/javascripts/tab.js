// JavaScript Document
//tab**************

  jQuery(function() {
      alert(1);
	 jQuery('.mokao_left > div').bind('click',function(){
	   		jQuery(this).addClass('mkl_h').siblings().removeClass('mkl_h');
			var index = jQuery('.mokao_left > div').index(this);
			jQuery('.mk_r_tab > .mk_r_div').eq(index).show().siblings().hide();
	});
 })
	