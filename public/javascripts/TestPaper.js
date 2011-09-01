// JavaScript Document
//tp_right右边点击切换
 jQuery(function() {
	jQuery('.first_title').bind('click',function(){
		jQuery(this).addClass('highLight').children('ul').show().end()
		.siblings().removeClass('highLight').children('ul').hide();
	})
 })
//tp_right右边随滑动条滑动
jQuery(function(){
	jQuery(window).scroll(function(){
		var top = jQuery(window).scrollTop();
		jQuery('.tp_right').stop().animate({top:top},1000);
})
	
})
 
 
 
//解析弹出层
jQuery(function(){
	jQuery('.jiexi_btn').click(function(e){
				jQuery('.jiexi_tab').css('display','block');
				jQuery('.jiexi_tab').css({
					                      'top':(e.pageY+20)+'px',
										  'left':(e.pageX-350)+'px'
										  });
		}
	)
	jQuery('.tab_t > a').click(function(){
				jQuery('.jiexi_tab').css('display','none')
				
		}
	)
	
}) 
//笔记弹出层
jQuery(function(){
	jQuery('.biji_btn').click(function(e){
				jQuery('.biji_tab').css('display','block');
				jQuery('.biji_tab').css({
					                      'top':(e.pageY+20)+'px',
										  'left':(e.pageX-350)+'px'
										  });
		}
	)
	jQuery('.tab_t > a').click(function(){
				jQuery('.biji_tab').css('display','none')
		}
	)
	
})
 
 
//回答问题，出现 保存和不确定 
jQuery(function(){
	jQuery(".answer_text :input").focus(function(){
  			jQuery(this).parent().next('.p_question_btn').show();
}); 
jQuery(".p_question_btn > button").focus(function(){
  			jQuery(this).parent().hide();
}); 
})