// JavaScript Document
$(function(){
    var thisCss;
	$('.zh_tab').bind('mouseover',function(){
		thisCss = $(this).css('z-index');
		$(this).css('z-index','10');
		$(this).addClass('zh_tab0').siblings().removeClass('zh_tab0');
		$(this).find('.zh_tab_title').css('color','#ffffff')
	})	
	$('.zh_tab').bind('mouseout',function(){
		$(this).css('z-index',thisCss);
		$(this).removeClass('zh_tab0');
		$(this).find('.zh_tab_title').css('color','#2875ae')
	})	
})
