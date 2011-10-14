// JavaScript Document
//tp_right右边随滑动条滑动
/*jQuery(function(){
    jQuery(window).scroll(function(){
        var top = jQuery(window).scrollTop();
        jQuery('.tp_right').stop().animate({
            top:top
        },1000);
    })
})*/

/*jQuery(function(){
    jQuery(window).scroll(function(){
        var top = jQuery(window).scrollTop();
        jQuery('.errorLibrary_right').stop().animate({
            top:top
        },1000);
    })
})*/
 
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
//    jQuery('.tab_t > a').click(function(){
//        jQuery('.jiexi_tab').css('display','none')
//    }
//    )
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



//提示框弹出层
function show_flash_div() {
    (function(){
        var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
        var win_height = document.documentElement.clientHeight;//jQuery(document).height();
        var win_width = jQuery(window).width();
        var z_layer_height = jQuery('.tishi_tab').height();
        var z_layer_width = jQuery('.tishi_tab').width();

        jQuery('.tishi_tab').css('top',(win_height-z_layer_height)/2 + scolltop);
        jQuery('.tishi_tab').css('left',(win_width-z_layer_width)/2);
        jQuery('.tishi_tab').css('display','block');
        setTimeout(function(){
            jQuery('.tishi_tab').fadeTo("slow",0);
        }, 2500);
        setTimeout(function(){
            jQuery('.tishi_tab').css('display','none');
        }, 3000);
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


//function report_error(paper_id,paper_title,user_id,user_name,description){
//    jQuery('.upErrorTo_tab').css('display','block');
//    jQuery('.upErrorTo_btn').click(function(e){
//    jQuery('.upErrorTo_tab').css({
//        'top':(e.pageY+10)+'px',
//        'left':(e.pageX-30)+'px'
//    });
//}


//function report_error(question_id, problem_id, examination_id, paper_id, problem_path, question_path) {
//    new Ajax.Updater("biji_tab", "/user/notes/"+question_id+"/load_note",
//    {
//        asynchronous:true,
//        evalScripts:true,
//        method:"post",
//        onComplete:function(request){
//            prepare_params(problem_id, examination_id, paper_id, problem_path, question_path)
//        },
//        parameters:'problem_id='+problem_id+'&examination_id='+examination_id+'&paper_id='+paper_id+'&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs=')
//    });
//    return false;
//}


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

