// JavaScript Document
// 自动轮换内容
$(document).ready(function(){
	var objStr = ".change ul li";
	$(objStr + ":not(:first)").css("display","none");
	setInterval(function(){
	if( $(objStr + ":last").is(":visible")){
		$(objStr + ":first").fadeIn("slow").addClass("in");
		$(objStr + ":last").hide()
	}
	else{
		$(objStr + ":visible").addClass("in");
		$(objStr + ".in").next().fadeIn("slow");
		$(objStr + ".in").hide().removeClass("in")}
	},4000) //每3秒钟切换
})

<!-- 自动轮换内容 -->