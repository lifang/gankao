// JavaScript Document
//tab**************
 $(function() {
	 $('.mokao_left > div').bind('click',function(){
	   		$(this).addClass('mkl_h').siblings().removeClass('mkl_h');
			var index = $('.mokao_left > div').index(this);
			$('.mokao_right > .mk_r_div').eq(index).show().siblings().hide();
	});
 })
	