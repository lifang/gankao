// JavaScript Document
//noteBook_right右边随滑动条滑动
$(function(){
	$(window).scroll(function(){
		var top = $(window).scrollTop();
		$('.noteBook_right').stop().animate({top:top},1000);
})
	
})