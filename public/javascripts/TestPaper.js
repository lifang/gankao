// JavaScript Document
//tp_right右边随滑动条滑动
jQuery(function(){
    jQuery(window).scroll(function(){
        var top = jQuery(window).scrollTop();
        jQuery('.tp_right').stop().animate({
            top:top
        },1000);
    })
})

jQuery(function(){
    jQuery(window).scroll(function(){
        var top = jQuery(window).scrollTop();
        jQuery('.errorLibrary_right').stop().animate({
            top:top
        },1000);
    })
})
 
//解析弹出层
jQuery(function(){
    jQuery('.jiexi_btn').click(function(e){
        var btn_id = this.id;
        jQuery('.jiexi_tab').css('display','block');
        jQuery('.jiexi_tab').css({
            'top':(e.pageY+20)+'px',
            'left':(e.pageX-350)+'px'
        });
        jQuery('#answer').html("正确答案 " + jQuery('#' + btn_id + '_answer').attr("value"));
        jQuery('#analysis').html(jQuery('#' + btn_id + '_analysis').attr("value"));
    }
    )
    jQuery('.tab_t > a').click(function(){
        jQuery('.jiexi_tab').css('display','none')
    }
    )
})

//笔记弹出层
jQuery(function(){
    jQuery('.biji_btn').click(function(e){
        jQuery('.biji_tab').css('display','block');
        jQuery('.biji_tab').css({
            'top':(e.pageY+20)+'px',
            'left':(e.pageX-350)+'px'
        });
    }
    )
    jQuery('.tab_t > a').click(function(){
        jQuery('.biji_tab').css('display','none')
    }
    )

})

//提示框弹出层
function show_flash_div() {
    (function(){
        var win_height = jQuery(window).height();
        var win_width = jQuery(window).width();
        var z_layer_height = jQuery('.tishi_tab').height();
        var z_layer_width = jQuery('.tishi_tab').width();

        jQuery('.tishi_tab').css('top',(win_height-z_layer_height)/2);
        jQuery('.tishi_tab').css('left',(win_width-z_layer_width)/2);
        jQuery('.tishi_tab').css('display','block');
        
        setTimeout(function(){
            jQuery('.tishi_tab').fadeTo("slow",0);
        }, 1500);
    })(jQuery)
}