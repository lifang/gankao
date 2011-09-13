// JavaScript Document
// 自动轮换内容
jQuery(document).ready(function(){
	var objStr = ".change ul li";
	jQuery(objStr + ":not(:first)").css("display","none");
	setInterval(function(){
	if( jQuery(objStr + ":last").is(":visible")){
		jQuery(objStr + ":first").fadeIn("slow").addClass("in");
		jQuery(objStr + ":last").hide()
	}
	else{
		jQuery(objStr + ":visible").addClass("in");
		jQuery(objStr + ".in").next().fadeIn("slow");
		jQuery(objStr + ".in").hide().removeClass("in")}
	},4000) //每3秒钟切换
})