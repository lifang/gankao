// JavaScript Document
//tab**************

jQuery(function() {
    jQuery('.mokao_left > div').bind('click',function(){
        jQuery(this).addClass('mkl_h').siblings().removeClass('mkl_h');
        var index = jQuery('.mokao_left > div').index(this);
        jQuery('.mk_r_tab > .mk_r_div').eq(index).show().siblings().hide();

    });
})

function tishi_hide(){
    jQuery('.cz_tishi').hide();
    jQuery('.zhezhao').hide();
    window.location.href="/competes";
}


function tishi(){
    var doc_height = jQuery(document).height();
    //var doc_width = $(document).width();
    var win_height = jQuery(window).height();
    var win_width = jQuery(window).width();
    var s_layer_height = jQuery('.cz_tishi').height();
    var s_layer_width = jQuery('.cz_tishi').width();
    jQuery('.zhezhao').css('display','block');
    jQuery('.zhezhao').css('height',doc_height);
    jQuery('.cz_tishi').css('top',(win_height-s_layer_height)/2)
    jQuery('.cz_tishi').css('left',(win_width-s_layer_width)/2);
    jQuery('.cz_tishi').css('display','block');
    //$('.serviceArea').fadeTo("slow", 1);
    //alert($(document).height())
    window.open("/competes/alipay_exercise")
}
function vip_tishi(){
    var doc_height = jQuery(document).height();
    //var doc_width = $(document).width();
    var win_height = jQuery(window).height();
    var win_width = jQuery(window).width();
    var s_layer_height = jQuery('.cz_tishi').height();
    var s_layer_width = jQuery('.cz_tishi').width();
    jQuery('.zhezhao').css('display','block');
    jQuery('.zhezhao').css('height',doc_height);
    jQuery('.cz_tishi').css('top',(win_height-s_layer_height)/2)
    jQuery('.cz_tishi').css('left',(win_width-s_layer_width)/2);
    jQuery('.cz_tishi').css('display','block');
    //$('.serviceArea').fadeTo("slow", 1);
    //alert($(document).height())
    window.open("/user/alipays/alipay_request")
}

function vip_tishi_hide(){
    jQuery('.cz_tishi').hide();
    jQuery('.zhezhao').hide();
    window.location.href="/users/get_vip"
}


//显示考试倒计时
var exercise_time_start = null;
var start_time=null;
var exercise_timer=null;
function show_exam_time() {
    start_time =Math.floor((new Date("2011-11-22")-new Date())/1000);
    // 注意setInterval函数: 时间逝去100(毫秒)后, onTimer才开始执行
    if (start_time != 0) {
        exercise_time_start = new Date();
        exercise_timer = self.setInterval(function(){
            onTimer();
        }, 100);
    }
}

// 倒计时函数
function onTimer() {
    var date_start = new Date();
    if (start_time <= 0) {
        window.onbeforeunload = null;
        window.clearInterval(exercise_timer);
        setTimeout(function(){
            document.getElementById("exercise_timer").innerHTML="报名日期已截止";
        }, 100);
        return;
    }
    var current_time = start_time;
    var d=  Math.floor(current_time/(3600*24))
    var m = Math.floor((current_time/(60))%60);
    var h = Math.floor(current_time/(3600)%24);
    var sd= d < 10 ? ("0" + d) : d;
    var sm = m < 10 ? ("0" + m) : m;
    var sh = h < 10 ? ("0" + h) : h;
    document.getElementById("exercise_timer").innerHTML = "<span>"+sd+"</span> 天 <span>"+ sh +"</span> 时 <span>"+ sm+"</span> 分 <span>";
    var date_end = new Date();
    if (start_time != 0) {
        if ((date_end - exercise_time_start) > 500 && (date_end - exercise_time_start) < 5000) {
            start_time = Math.round((start_time - (date_end - exercise_time_start)/1000)*10)/10;
        } else {
            start_time = Math.round((start_time - 0.1 - (date_end - date_start)/1000)*10)/10;
        }
    }
    exercise_time_start = date_end;
}

//提示框设置
function generate_flash_div(style) {
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var win_width = jQuery(window).width();
    var z_layer_height = jQuery(style).height();
    var z_layer_width = jQuery(style).width();
    jQuery(style).css('top',(win_height-z_layer_height)/2 + scolltop);
    jQuery(style).css('left',(win_width-z_layer_width)/2);
    jQuery(style).css('display','block');
}

//提示框弹出层
function show_flash_div() {
    (function(){
        generate_flash_div(".tishi_tab");
        setTimeout(function(){
            jQuery('.tishi_tab').fadeTo("slow",0);
        }, 2500);
        setTimeout(function(){
            jQuery('.tishi_tab').css('display','none');
        }, 3000);
    })(jQuery)
}