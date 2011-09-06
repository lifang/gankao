// JavaScript Document
$(function(){
    $('.tab_t > a').click(function(){
        $('.jiexi_tab').css('display','none')
				
    }
    )
    $('.task_title > a').click(function(e){
        $('.jiexi_tab').css('display','block')
        $('.jiexi_tab').css({
            'top':(e.pageY+30)+'px',
            'left':(e.pageX-340)+'px'
        });
    }
    )
})