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
//    jQuery('.tab_t > a').click(function(){
//        jQuery('.biji_tab').css('display','none')
//    }
//    )

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
        }, 1500);
        setTimeout(function(){
            jQuery('.tishi_tab').css('display','none');
        }, 2000);
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
//        jQuery('.tab_t > a').click(function(){
//            jQuery('.jiexi_tab').css('display','none')
//        }
//        )
    })(jQuery)
}

function close_tab(tab) {
    tab.parentNode.parentNode.style.display = "none";
}