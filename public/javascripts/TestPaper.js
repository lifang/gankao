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