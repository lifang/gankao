// JavaScript Document
$(function(){
	$('.lianx_pat').click(function(){
		$('.moveBlock').animate( { left: '38px' } , 500 );
		$('.p_question_list').removeClass('question_no').addClass('question_yes').find('li').css('background','#ffffff');
		$('.review_btn').css('display','none');
	});
	$('.chay_pat').click(function(){
		$('.moveBlock').animate( { left: '1px' } , 500 );
		$('.p_question_list').removeClass('question_yes').addClass('question_no').find('li').css('background','');
		$('.review_btn').css('display','block');
	})
})