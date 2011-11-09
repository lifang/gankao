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
    window.location.href="/comptes";
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
