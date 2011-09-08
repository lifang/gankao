
jQuery.noConflict();
// JavaScript Document
jQuery(function(){
    var thisCss;
	jQuery('.zh_tab').bind('mouseover',function(){
		thisCss = jQuery(this).css('z-index');
		jQuery(this).css('z-index','10');
		jQuery(this).addClass('zh_tab0').siblings().removeClass('zh_tab0');
		jQuery(this).find('.zh_tab_title').css('color','#ffffff')
	})	
	jQuery('.zh_tab').bind('mouseout',function(){
		jQuery(this).css('z-index',thisCss);
		jQuery(this).removeClass('zh_tab0');
		jQuery(this).find('.zh_tab_title').css('color','#2875ae')
	})	
})
