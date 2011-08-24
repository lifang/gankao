
function sltall_price(checkstatus,checkbox){
    var d=document.getElementsByName(checkbox);
    var number=$("number").value;
    var n=0;
    var checked_ids =0;
    for(var i=0; i<d.length; i++){
        if (d[i].disabled ==false){
            d[i].checked=checkstatus;
            if (d[i].checked == true) {
                n +=1;
                checked_ids += parseInt(d[i].value)
            }
        }
    }
    if (n ==number){
        $("exam_getvalue").innerHTML=$("favourable").value+"(打包优惠价)";
    }else{
        $("exam_getvalue").innerHTML = checked_ids;
    }
}
function get_price(checkbox){
    var sles=document.getElementsByName(checkbox);
    var checked_ids =0;
    var number=$("number").value;
    var n=0;
    for (var i=0;i<sles.length;i++) {
        if (sles[i].checked) {
            n +=1;
            checked_ids += parseInt(sles[i].value);
        }
        if (sles[i].disabled==true){
            $("packed").checked=false;
        }
    }
    if(number==0){
        $("exam_getvalue").innerHTML="没有考试";
        $("over").disabled=true;
        $("packed").checked=false;
    }else{
        if (n ==number){
            $("exam_getvalue").innerHTML=$("favourable").value+"(打包优惠价)";
        }else{
            $("exam_getvalue").innerHTML = checked_ids;
        }
    }
}


function show_name(first,second) {
    $(first).style.display ="block";
    $(second).style.display ="none";
}

function check_password() {
    var password=$("user_password").value;
    var confirmation=$("user_password_confirmation").value;
    if (password == null || password.length ==0||password.length>40||password.length<6){
        document.getElementById("passwordErr").innerHTML="<font color = 'red'>密码不能为空，长度在6和20之间</font>";
        return false;
    } else	{
        document.getElementById("passwordErr").innerHTML="";
        if (confirmation != password){
            document.getElementById("confirmationErr").innerHTML="<font color = 'red'>两次输入的密码不一致，请重新输入</font>";
            return false;
        }else{
            document.getElementById("confirmationErr").innerHTML="";
            return ture;
        }
    }
}
close_question_info_id=0
function compare_value(id,compare_id){
    var check_mobile = new RegExp(/^[0-9]{1,2}$/);
    if (close_question_info_id != 0) {  //关闭查看框
        if (parseInt(compare_id)==0){
            document.getElementById("question_info_"+close_question_info_id).style.display="none";
            close_question_info_id = 0;
        }else{
            var arry=id.split("_");
            var i;
            for(i=1;i<arry.length;i++){
                var input_value=$("single_value_"+arry[i]).value;
                var fact_value=$("fact_value_"+arry[i]).value;
                var reason=$("reason_for_"+arry[i]).value;
                if (parseInt(fact_value) < parseInt(input_value)||parseInt(input_value)<0||input_value==""){
                    $("if_submited_"+arry[i]).value =0;
                    $("flash_part_"+arry[i]).innerHTML="<font color = 'red'>请您输入合理的分值。</font>";
                    return false;
                }
                else{
                    if (check_mobile.test(input_value)){
                        $("flash_part_"+arry[i]).innerHTML="";
                        if(reason==""||reason.length==0){
                            $("flash_part_"+arry[i]).innerHTML="<font color = 'red'>请输入评分理由。</font>";

                        }else{
                            $("if_submited_"+arry[i]).value =1;
                            if (i==arry.length-1){
                                document.getElementById("question_info_"+close_question_info_id).style.display="none";
                                close_question_info_id = 0;
                                active_button();
                            }
                        }
                    }
                    else{
                        $("flash_part_"+arry[i]).innerHTML="<font color = 'red'>得分只能是数值。</font>";
                    }
                }
            }
        }
    }
    document.getElementById("question_info_"+id).style.display="block";
    close_question_info_id = id;
    active_button();
}
function active_button(){
    $("flash_notice").innerHTML="";
    var flag=0;
    var str=$("problem_id").value;
    var n=str.split(",");
    for(i=1;i<n.length;i++){
        var value=$("single_value_"+n[i]).value;
        var reason=$("reason_for_"+n[i]).value;
        flag=1;
        if(value ==""){
            $("if_submited_"+n[i]).value =0;
            flag=0;
            $("button_id").disabled=true;
            return false;
        }else{
            if(reason==""){
                $("if_submited_"+n[i]).value =0;
                flag=0;
                $("button_id").disabled=true;
                return false;
            }

        }
    }
    if(flag==1){
        button_status();
        if(button_status()){
            $("button_id").disabled=false;
        }
        else{
            $("flash_notice").innerHTML="<font color = 'red'>请检查批阅分数</font>";
            $("button_id").disabled=true;
        }
    }else{
        $("button_id").disabled=true;
    }
}
function button_status(){
    var str=$("problem_id").value;
    var  flag=0;
    var i;
    var n=str.split(",");
    for(i=0;i<n.length-1;i++){
        var  value=$("if_submited_"+n[i+1]).value;
        flag=1;
        if(value==0){
            flag=0;
            return false;
        }
    }
    if (flag==1){
        return true;
    }
    else{
        return false;
    }
}

num=0;
function give_me_value(in1,id){
    var n = $(in1).value;
    new Ajax.Updater("in1", "/rater/exam_raters/"+id +"/edit_value",
    {
        asynchronous:true,
        evalScripts:true,
        method:'post',
        parameters:'value='+ n +'&id='+ id +'&authenticity_token=' + encodeURIComponent('5kqVHCOuTTCFFQkywU0UzTAENJi1jcPs0+QKEpVa4lQ=')
    });

    return false;

}
function edit_score(id, user_id, question_score){
    var score=$("edit_score_"+id).value;
    if ((question_score < parseInt(score)) || parseInt(score)<0){
        $("last_score_"+id).innerHTML="您输入的分值有误";
        return false;
    }else{
        new Ajax.Updater("last_score_"+id, "/user/exam_users/"+id +"/edit_score",
        {
            asynchronous:true,
            evalScripts:true,
            method:'post',
            onComplete:function(request){
                update_score(id, score, user_id, question_score)
            },
            parameters:'score='+score +'&user_id='+user_id +'&authenticity_token=' + encodeURIComponent('5kqVHCOuTTCFFQkywU0UzTAENJi1jcPs0+QKEpVa4lQ=')
        });
        return false;
    }

}

//将小题的分值变成可编辑状态
function load_score_edit(question_id, user_score, exam_user_id, score) {
    var str = "得<input size='4' id='edit_score_"+ question_id +"' value='"+ user_score +"' />分\n\
        <input type='button' onclick='javascript:edit_score("+ question_id +","+ exam_user_id +",\""+ score +"\")' value='确定' />";
    $("user_score_" + question_id).innerHTML = str;
}

//保存分值成功
function update_score(question_id, user_score, exam_user_id, question_score) {
    var str = "<font color='red'>得"+ user_score +"分</font><a href='javascript:void(0);'\n\
        onclick='javascript:load_score_edit("+ question_id +", \""+ user_score +"\", "+ exam_user_id +", \""+ question_score +"\")'>\n\
       <font color='blue'>编辑</font></a>";
    $("user_score_" + question_id).innerHTML = str;
}
function button_fail(button_id, pic_id) {
    $(""+pic_id).show();
    $(""+button_id).hide();
}

function cast_account(id){
    var sles=document.getElementsByName("all_price"+id);
    var checked_ids =0;
    var n=0;
    var  favourable=$("favourable"+id).value;
    var agency_cost=$("agency_cost"+id).value;
    var number=$("number"+id).value;
    for (var i=0;i<sles.length;i++) {
        if (sles[i].checked) {
            n +=1;
            checked_ids += parseInt(sles[i].value);
        }
        if (sles[i].disabled==true){
            $("packed"+id).checked=false;
        }
    }
    if(number==0){
        $("exam_getvalue"+id).innerHTML="没有考试";
        $("over"+id).disabled=true;
        $("packed"+id).checked=false;
    }else{
        if (n ==number){
            $("exam_getvalue"+id).innerHTML=favourable+"(打包优惠价)";
            if(parseInt(favourable)==0){
                $("fact_value"+id).innerHTML=0;
            }else{
                $("fact_value"+id).innerHTML=parseInt(favourable)-parseInt(agency_cost);
            }
        }else{
            $("exam_getvalue"+id).innerHTML = checked_ids;
            if (checked_ids==0){
                $("fact_value"+id).innerHTML=0;
            }else{
                $("fact_value"+id).innerHTML=checked_ids-parseInt(agency_cost);
            }
        }
    }
}

function pay_price(checkstatus,id){
    var d=document.getElementsByName("all_price"+id);
    var number=$("number"+id).value;
    var n=0;
    var checked_ids =0;
    var  favourable=$("favourable"+id).value;
    var agency_cost=$("agency_cost"+id).value;
    for(var i=0; i<d.length; i++){
        if (d[i].disabled ==false){
            d[i].checked=checkstatus;
            if (d[i].checked == true) {
                n +=1;
                checked_ids += parseInt(d[i].value)
            }
        }
    }
    if(number==0){
        $("exam_getvalue"+id).innerHTML="没有考试";
        $("over"+id).disabled=true;
        $("packed"+id).checked=false;
    }else{
        if (n==number){
            $("exam_getvalue"+id).innerHTML=favourable+"(打包优惠价)";
            $("fact_value"+id).innerHTML=parseInt(favourable)-parseInt(agency_cost);
        }else{
            $("exam_getvalue"+id).innerHTML = checked_ids;
            $("exam_getvalue"+id).innerHTML = checked_ids;
            if (checked_ids==0){
                $("fact_value"+id).innerHTML=0;
            }else{
                $("fact_value"+id).innerHTML=checked_ids-parseInt(agency_cost);
            }
        }
    }
}

function show_category(id){
    var num=$("category_num").value.split(",");
    var i;
    if (id==0){
        $("partial"+num[0]).style.display="block";
    }else{
        for(i=0;i<num.length;i++){
            if(num[i]!= id){
                $("partial"+num[i]).style.display="none";
            }else{
                $("partial"+id).style.display="block";
            }
        }
    }
}

function get_user_info(id){
    if(input_value(id)==true){
        new Ajax.Updater("user_info"+id, "/payments/"+ id +"/search_account",
        {
            asynchronous:true,
            evalScripts:true,
            method:'post',
            parameters:'agency_account'+ id+'='+$("agency_account"+id).value +'&authenticity_token=' + encodeURIComponent('5kqVHCOuTTCFFQkywU0UzTAENJi1jcPs0+QKEpVa4lQ=')
        });
        return false;
    }else{
        return false;
    }
}
function input_value(id){
    var value=$("agency_account"+id).value;
    if (value=="账号/邮箱"||value==""){
        $("user_info"+id).innerHTML="请输入账户名称";
        return false;
    }else{
        return true;
    }
}

function ajax_problem_info(){
    new Ajax.Updater("show_div" , "/exam_lists/show_problem",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        parameters:'&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs='        )
    });
    return false;
}

function start_note(question_id, problem_id, examination_id, paper_id) {
    $("start_note_" + question_id).style.display = "block";
    $("note_" + question_id).style.display = "none";
    new Ajax.Updater("start_note_" + question_id , "/user/notes/"+question_id+"/load_note",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        parameters:'problem_id='+problem_id+'&examination_id='+examination_id+'&paper_id='+paper_id+'&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs=')
    });
    return false;
}

function cancel_note(question_id) {
    $("start_note_" + question_id).style.display = "none";
    $("note_" + question_id).style.display = "block";
    $("note_text_" + question_id).value = "";
}

