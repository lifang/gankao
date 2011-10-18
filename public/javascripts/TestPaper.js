//解析弹出层
jQuery(function(){
    jQuery('.jiexi_btn').click(function(e){
        jQuery('.biji_tab').css('display','none');
        var btn_id = this.id;
        jQuery('.jiexi_tab').css('display','block');
        jQuery('.jiexi_tab').css({
            'top':(e.pageY+20)+'px',
            'left':(e.pageX-30)+'px'
        });
        jQuery('#answer').html(jQuery('#' + btn_id + '_answer').attr("value"));
        jQuery('#analysis').html(jQuery('#' + btn_id + '_analysis').attr("value"));
    }
    )
})

//笔记弹出层
jQuery(function(){
    jQuery('.biji_btn').click(function(e){
        jQuery('.jiexi_tab').css('display','none');
        jQuery('.biji_tab').css('display','block');
        jQuery('.biji_tab').css({
            'top':(e.pageY+20)+'px',
            'left':(e.pageX-30)+'px'
        });
    }
    )

})

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

//弹出不自动关闭的提示框
function show_flash_not_close() {
    (function(){
        generate_flash_div(".white_tab_box");
    })(jQuery)
}


function show_analysis(btn_id) {
    (function(){
        jQuery('.jiexi_tab').css('display','block');
        jQuery('.jiexi_tab').css({
            'top':(this.event.pageY+20)+'px',
            'left':(this.event.pageX-30)+'px'
        });
        jQuery('#answer').html(jQuery('#' + btn_id + '_answer').attr("value"));
        jQuery('#analysis').html(jQuery('#' + btn_id + '_analysis').attr("value"));
    })(jQuery)
}

function close_tab(tab) {
    tab.parentNode.parentNode.style.display = "none";
}

function flash_remove(tab) {
    tab.parentNode.parentNode.removeChild(tab.parentNode);
}

function report_error(question_index,exam_user_id){
    (function(){
        jQuery('.upErrorTo_tab').css('display','block');
        jQuery('.upErrorTo_tab').css({
            'top':(this.event.pageY+20)+'px',
            'left':(this.event.pageX-30)+'px'
        });
    })(jQuery)
    var str="<a href=\"javascript:send_ajax_report_error(1,"+question_index+","+exam_user_id+");\">题目错误</a><a href=\"javascript:send_ajax_report_error(2,"+question_index+","+exam_user_id+");\">答案错误</a><a href=\"javascript:send_ajax_report_error(3,"+question_index+","+exam_user_id+");\">解析错误</a>"
    document.getElementById("upErrorTo_tab").innerHTML=str;
}

function send_ajax_report_error(error_type,question_index,exam_user_id){
    new Ajax.Updater("note_div", "/user/notes/"+exam_user_id+"/report_error",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            jQuery('.upErrorTo_tab').css('display','none');
        },
        parameters:'error_type='+error_type+'&question_index='+question_index+'&exam_user_id='+exam_user_id+'&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs=')
    });
    return false;
}

//显示错题模式
jQuery(function(){
    jQuery('.patternText').mouseover(function(e){
        jQuery('.pattern_tab').css('display','block');
        jQuery('.pattern_tab').css({
            'top':(e.pageY+5)+'px',
            'left':(e.pageX-30)+'px'
        });
    })
    jQuery('.patternText').mouseout(function(e){
        jQuery('.pattern_tab').css('display','none')
    })

})

