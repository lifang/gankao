close_question_info_id = 0
close_create_question_id = 0
close_edit_problem_id = 0
close_edit_block_id = 0
close_mavin_question_id = 0

//if (window.onbeforeunload == undefined) {
//    window.onbeforeunload=function() {
//        return "您还未保存试卷，确定要离开当前页面么？";
//    }
//}
function save_paper_js(paper_id) {
    $("spinner_for_submit").show();
    $("paper_js_button").hide();
    window.onbeforeunload = undefined;
    window.location.href="/papers/"+ paper_id +"/create_all_paper";
}

//整体处理各个模块div的显示和关闭
function manage_div(open_div_id, div_sup_name) {
    if (close_edit_block_id != 0  && div_sup_name != "edit_block") {   //关闭模块编辑框
        document.getElementById("edit_block_" + close_edit_block_id).style.display = "none";
        close_edit_block_id = 0;
    }
    if (close_question_info_id != 0  && div_sup_name != "question_info") {   //关闭查看框
        document.getElementById("question_info_" + close_question_info_id).style.display = "none";
        close_question_info_id = 0;
    }
    if (close_edit_problem_id != 0 &&  div_sup_name != "edit_problem") {   //关闭编辑框
        document.getElementById("edit_problem_"+close_edit_problem_id).innerHTML="";
        close_edit_problem_id = 0;
    }

    if(close_create_question_id != 0 &&  div_sup_name != "create_question"){
        document.getElementById("create_question_"+close_create_question_id).innerHTML="";
        close_create_question_id = 0;
    }

    if(close_mavin_question_id != 0  && div_sup_name != "mavin_question"){
        document.getElementById("mavin_question_"+close_mavin_question_id).innerHTML="";
        close_mavin_question_id = 0;
    }
    
    if (div_sup_name == "new_module") {
        if(document.getElementById("new_module").style.display=="block"){
            document.getElementById("new_module").style.display="none";
        }else{
            document.getElementById("new_module").style.display="block";
        }
    }
}

//创建问题，关闭其它正在打开的div的框
function create_question(id, paper_id){
    manage_div(id, "create_question");
    if(close_create_question_id != 0 && close_create_question_id != id){
        document.getElementById("create_question_"+close_create_question_id).innerHTML = "";
    }
    if (document.getElementById("create_question_"+id).innerHTML == "") {
        load_create_problem(id, paper_id, "create");
    }
    close_create_question_id = id;

}

//将选中的题目的类型提交给新创建试题块的type隐藏域
function get_question_type(block_id, paper_id, correct_type, remote_div) {
    var problem_type = "";
    var question_type = "";
    var types = document.getElementsByName("type_radio_" + block_id);
    for (var i=0; i<types.length; i++) {
        if (types[i].checked == true) {
            problem_type = types[i].value;
        }
    }
    $("real_type_" + block_id).value = problem_type;
    $("choose_que_type_div_" + block_id).style.display = "none";
    if (correct_type == null) {
        question_type = problem_type;
    }
    else {
        question_type = correct_type;
    }
    if (remote_div == "remote_que_div_") {
        $("choose_coll_que_" + block_id).style.display = "none";
        $("choose_coll_que_link_" + block_id).style.display = "none";
    }
    new Ajax.Updater("" + remote_div + block_id, "/paper_blocks/" + block_id + "/choose_type",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        parameters:'paper_id=' + paper_id + '&problem_type=' + problem_type + '&question_type='+ question_type +
        '&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs=')
    });
    return false;
}

//增加综合题的小题
function new_question(block_id) {
    if(question_validate()==false){
        return false;
    }
    var hash_str = "{1=>1";
    if ($("problem_description")!= null && $("problem_description").value != "") {
        hash_str += ",|,diescription=>"+  $("problem_description").value + "";
    }
    hash_str += ",|,correct_type=>"+  $("problem_correct_type").value + "";
    if  ($("problem_attr_sum") != null && $("problem_attr_sum").value != "") {
        hash_str += ",|,problem_attr_sum=>"+  $("problem_attr_sum").value + "";
    }
    var attr_value = "";
    var attr_answer ="";
    if (parseFloat($("problem_correct_type").value) == 0) {
        for (var i=1; i<=parseFloat($("problem_attr_sum").value); i++) {
            if($("problem_attr" + i + "_value")!=null){
                attr_value += $("problem_attr" + i + "_value").value;
                attr_value += ";|;"
                var attr_key = document.getElementsByName("attr_key");
                if (attr_key != null) {
                    for (var j=0; j<attr_key.length; j++) {
                        if (attr_key[j].checked == true) {
                            var answer_id = attr_key[j].value;
                            attr_answer = $("problem_attr" + answer_id + "_value").value;
                        }
                    }
                }
            }
        }
    } else if (parseFloat($("problem_correct_type").value) == 1) {
        for (var k=1; k<=parseFloat($("problem_attr_sum").value); k++) {
            if($("problem_attr" + k + "_value")!=null){
                attr_value += $("problem_attr" + k + "_value").value;
                if (k < parseFloat($("problem_attr_sum").value)) {
                    attr_value += ";|;"
                }
                var more_attr_key = document.getElementsByName("attr" + k + "_key");
                if (more_attr_key[0].checked == true) {
                    if (attr_answer == "") {
                        attr_answer =  $("problem_attr" + k + "_value").value;
                    } else {
                        attr_answer =  attr_answer + ";|;" + $("problem_attr" + k + "_value").value;
                    }
                }
            }
        }
    } else if (parseFloat($("problem_correct_type").value) == 2) {
        var judge_attr_key = document.getElementsByName("attr_key");
        for (var l=0; l<judge_attr_key.length; l++) {
            if (judge_attr_key[l].checked == true) {
                attr_answer =  judge_attr_key[l].value;
            }
        }
    } else {
        attr_answer = $("problem_answer").value;
    }
    hash_str += ",|,answer=>" +  attr_answer + "";
    hash_str += ",|,attr_value=>"+ attr_value +"";

    if ($("problem_score") != null && $("problem_score").value != '') {
        hash_str += ",|,score=>"+  $("problem_score").value +"";
    }
    if ($("problem_analysis") != null && $("problem_analysis").value != "") {
        hash_str += ",|,analysis=>"+  $("problem_analysis").value +"";
    }
    if ($("tag") != null && $("tag").value != "") {
        hash_str += ",|,tag=>"+  $("tag").value +"";
    }
    hash_str += "}||";
    var parent = $("real_single_question_" + block_id);
    var div_length = parent.childNodes.length + 1;
    var div = document.createElement("div");
    div.innerHTML = "<div id='question_'"+ div_length +">" + $("problem_description").value + "</div><div>" + attr_value.split(";|;") +"</div>";
    div.innerHTML += "<div style='float:right;'><a herf='#'>删除</a></div><div class='clear'></div>";
    parent.appendChild(div);
    $("remote_que_div_" + block_id).innerHTML = "";
    $("choose_coll_que_link_" + block_id).style.display = "block";
    $("single_question_" + block_id).value += hash_str;
}

//验证添加综合题的小题
function question_validate(){
    if ($("problem_description")!= null && $("problem_description").value == "") {
        alert("小题描述不能为空。");
        return false;
    }
    if (parseFloat($("problem_correct_type").value) == 0 ||parseFloat($("problem_correct_type").value) == 1){
        var answer_array=new Array;
        for (var i=1; i<=parseFloat($("problem_attr_sum").value); i++) {
            if ($("problem_attr" + i + "_value")!=null && $("problem_attr" + i + "_value").value=="") {
                alert("选项不能为空。");
                return false;
            }
            if($("problem_attr" + i + "_value")!=null){
            answer_array.push($("problem_attr" + i + "_value").value);
            }
        }
        var answer_array_sort=answer_array.sort();
        for(var i=0;i<answer_array.length;i++){
            if (answer_array_sort[i]==answer_array_sort[i+1]){
                alert("选项不能重复 ： "+answer_array_sort[i]);
                return false;
            }
        }

        if(document.getElementsByName("attr_key").length!=0) {
            var checked_num=0;
            var attr_key = document.getElementsByName("attr_key");
            var attr_sum = document.getElementById("problem_attr_sum").value;
            for (var j=1; j<=attr_sum; j++) {
                if (attr_key[j-1]!=null && attr_key[j-1].checked == true) {
                    checked_num++;
                }
            }
            if (checked_num==0){
                alert("请设置正确选项。");
                return false;
            }
        }     //单选题，验证设置选项

        if(parseFloat($("problem_correct_type").value) == 1) {
            var checked_num=0;
            for (var j=1; j<=parseFloat($("problem_attr_sum").value); j++) {
                var attr_key = document.getElementById("problem_attr_key_"+j);
                if (attr_key!=null && attr_key.value == j && attr_key.checked == true) {
                    checked_num++;
                }
            }
            if(checked_num==0){
                alert("请设置正确选项。");
                return false;
            }
        }     //多选题，验证设置选项
    }

    
    if(parseFloat($("problem_correct_type").value) == 3||parseFloat($("problem_correct_type").value) == 5){
        var problem_answer = $("problem_answer").value;
        if(problem_answer==""){
            alert("答案不能为空。");
            return false;
        }
    }   //验证答案不能为空
}   

//修改综合题小题
function generate_edit_questions(problem_id, problem_type) {
    if(edit_problem_validate(problem_id)==false){
        return false;
    } 
    if (parseFloat(problem_type) == 4) {
        var hash_str = "";
        var ids_str = $("all_question_ids_" + problem_id).value;
        var question_ids = ids_str.replace("[", "").replace("]", "").replace(/ /g , "").split(",");
        for (var i=0; i<question_ids.length; i++) {
            var attr_value = "";
            var attr_answer ="";
            var question_div = $("remote_question_" + question_ids[i]);
            if (question_div != null && $("make_edit_" + question_ids[i]).value == "1") {
                var inputs = question_div.getElementsByTagName("input");
                hash_str += "{1=>1,|,question_id=>" + question_ids[i];
                if (inputs != null && inputs[0] != null) {
                    var attr = parseFloat(inputs[1].value);
                    if (parseFloat(inputs[0].value) == 0) {
                        var attr_array = [];
                        for (var k=2; k<inputs.length; k++) {
                            if (attr > 0) {
                                for (var m=1; m<=attr; m++) {
                                    if (inputs[k].id == "problem_attr_key_" + m) {
                                        if(inputs[k+1].value==""){
                                            alert("选项不能为空！");
                                            return false;
                                        }
                                        attr_array.push(inputs[k+1].value);
                                        attr_value += inputs[k+1].value + ";|;";
                                        if (inputs[k].checked == true) {
                                            attr_answer = inputs[k+1].value;
                                        }
                                    }
                                }
                            }
                            if (inputs[k].name == "problem[score]") {
                                hash_str += ",|,score=>"+  inputs[k].value +"";
                            }
                        }
                        var attr_array_sort=attr_array.sort();
//                        for(var q=0;q<attr_array.length;q++){
//                            if (attr_array_sort[q]==attr_array_sort[q+1]){
//                                alert("选项内容重复："+attr_array_sort[q]);
//                                return false;
//                            }
//                        }
                    } else if (parseFloat(inputs[0].value) == 1) {
                        var attr_array = [];
                        var answer_sum = 0;
                        for (var l=2; l<inputs.length; l++) {
                            if (attr > 0) {
                                for (var n=1; n<=attr; n++) {
                                    if (inputs[l].id == "problem_attr_key_" + n) {
                                        if(inputs[l+1].value==""){
                                            alert("选项不能为空！");
                                            return false;
                                        }
                                        attr_array.push(inputs[l+1].value);
                                        attr_value += inputs[l+1].value + ";|;";
                                        if (inputs[l].checked == true) {
                                            if (attr_answer == "") {
                                                attr_answer =  inputs[l+1].value;
                                            } else {
                                                attr_answer =  attr_answer + ";|;" + inputs[l+1].value;
                                            }
                                            answer_sum++;
                                        }
                                    }
                                }
                            }
                            if (inputs[l].name == "problem[score]") {
                                hash_str += ",|,score=>"+  inputs[l].value +"";
                            }
                        }
                        var attr_array_sort=attr_array.sort();
//                        for(var q=0;q<attr_array.length;q++){
//                            if (attr_array_sort[q]==attr_array_sort[q+1]){
//                                alert("选项内容重复："+attr_array_sort[q]);
//                                return false;
//                            }
//                        }
                        if(answer_sum==0){
                            alert("请设置正确答案。");
                            return false;
                        }
                    } else if (parseFloat(inputs[0].value) == 2) {
                        if (inputs[2].id == "problem_attr_key" && inputs[2].checked == true) {
                            attr_answer = inputs[2].value;
                        } else if (inputs[3].id == "problem_attr_key" && inputs[3].checked == true) {
                            attr_answer = inputs[3].value;
                        }
                        if (inputs[4].name == "problem[score]") {
                            hash_str += ",|,score=>"+  inputs[4].value +"";
                        }
                    } else {
                        if (inputs[2].name == "problem[score]") {
                            hash_str += ",|,score=>"+  inputs[2].value +"";
                        }
                    }
                    if (attr_answer != "") {
                        hash_str += ",|,answer=>" +  attr_answer + "";
                    }
                    hash_str += ",|,attr_value=>"+ attr_value +"";
                    var textarea = question_div.getElementsByTagName("textarea");
                    if (textarea != null) {
                        for (var j=0; j<textarea.length; j++) {
                            if (textarea[j].name == "problem[description]" && textarea[j].value==""){
                                alert("题目描述不能为空。");
                                return false;
                            }
                            if (textarea[j].id == "problem_answer" && textarea[j].value==""){
                                alert("答案不能为空。");
                                return false;
                            }

                            if (textarea[j].name == "problem[description]" && textarea[j].value != "") {
                                hash_str += ",|,diescription=>"+  textarea[j].value + "";
                            } else if (textarea[j].id == "problem_answer" && textarea[j].value != "") {
                                hash_str += ",|,answer=>" +  textarea[j].value + "";
                            } else if (textarea[j].name == "problem[analysis]" && textarea[j].value != "") {
                                hash_str += ",|,analysis=>" +  textarea[j].value + "";
                            }
                        }
                    }
                    hash_str += "}||";
                }
            }
        }
        $("edit_coll_question_" + problem_id).value = hash_str;
    }
    $("edit_form_" + problem_id).submit();
}

//取消添加小题
function cancel_question(block_id) {
    $("remote_que_div_" + block_id).innerHTML = "";
    $("choose_coll_que_" + block_id).style.display = "none";
    $("choose_coll_que_link_" + block_id).style.display = "block";
}

//显示富文本编辑器
function add_area(content_id, button) {
    var area = new nicEditor({
        fullPanel : true
    }).panelInstance(content_id);
    button.value = "普通文本";
    button.onclick = function onclick(event) {
        javascript:remove_area(area, content_id, button);
    };
}

//取消富文本编辑器
function remove_area(area,content_id, button) {
    area.removeInstance(content_id);
    button.value = "富文本";
    button.onclick = function onclick(event) {
        javascript:add_area(content_id, button);
    };
}

//打开选择题型的div
function choose_question_type(id){
    manage_div(-1, "choose_question_type");
    $("choose_que_type_div_" + id).style.display = "block";
}

//取消添加试题选择题目类型
function cancel_choose_que_type(block_id) {
    $("choose_que_type_div_" + block_id).style.display = "none";
}

//修改试卷基本信息
function change_info(){
    manage_div(-1, "change_info");
    document.getElementById("paper_edit_info").style.display="block";
    document.getElementById("paper_show_info").style.display="none";
}

//新建模块
function new_module(){
    manage_div(-1, "new_module");
}

//显示题目
function question_info(id){
    manage_div(id, "question_info");
    if(close_question_info_id != 0 && close_question_info_id != id){
        document.getElementById("question_info_" + close_question_info_id).style.display = "none";
    }
    document.getElementById("question_info_" + id).style.display = "block";
    close_question_info_id = id;
}

//编辑题目
function edit_problem(id,block_id,paper_id){
    manage_div(id, "edit_problem");
    if(close_edit_problem_id != 0 && close_edit_problem_id != id){
        document.getElementById("edit_problem_"+close_edit_problem_id).innerHTML = "";
    }
    if (document.getElementById("edit_problem_"+id).innerHTML == "") {
        load_edit_problem(id,block_id,paper_id);
    }
    close_edit_problem_id = id;


}

//载入修改题目面板
function load_edit_problem(problem_id,block_id,paper_id){
    new Ajax.Updater("edit_problem_" + problem_id, "/paper_blocks/load_edit_problem",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        parameters:'problem_id=' + problem_id + '&block_id=' + block_id + '&paper_id=' + paper_id+
        '&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs=')
    });
    return false;
}

//载入专家新建题目模板
function load_mavin_problem(block_id, paper_id) {
    manage_div(block_id, "mavin_question");
    if(close_mavin_question_id != 0 && close_mavin_question_id != block_id){
        document.getElementById("mavin_question_"+close_mavin_question_id).innerHTML = "";
    }

    if (document.getElementById("mavin_question_"+block_id).innerHTML == "") {
        load_create_problem(block_id, paper_id, 'mavin');
    }
    close_mavin_question_id = block_id;
    
}

//载入新建题目面板
function load_create_problem(block_id,paper_id, create_type){
    new Ajax.Updater(create_type + "_question_" + block_id, "/paper_blocks/load_create_problem",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            if (create_type == "create") {
                get_question_type(block_id, paper_id, null, "new_problem_");
            }
        },
        parameters:'block_id=' + block_id + '&paper_id=' + paper_id + '&type=' + create_type +
        '&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs=')
    });
    return false;
}


//编辑模块
function edit_block(id){
    manage_div(id, "edit_block");
    if(close_edit_block_id != 0 && close_edit_block_id != id){
        document.getElementById("edit_block_"+close_edit_block_id).style.display = "none";
    }
    document.getElementById("edit_block_"+id).style.display = "block";
    close_edit_block_id = id;
}

function show_choose_coll_que(block_id) {
    $("choose_coll_que_" + block_id).style.display = "block";
    $("choose_coll_que_link_" + block_id).style.display = "none";
}



//编辑综合题的题点
function edit_question(question_id, paper_id, xpath) {
    $("make_edit_" + question_id).value = "1";
    new Ajax.Updater("remote_question_" + question_id, "/questions/" + question_id + "/edit_question",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        parameters:'paper_id=' + paper_id + '&xpath=' + xpath + '&authenticity_token='
        + encodeURIComponent('Q3CnqJgIgZEqWnlCyD902sexHwkF7phBA8hPYM1Tqxc=')
    });
    return false;
}

function new_attr(type){
    if(type=="single_choose"){
        var attr_sum_element=document.getElementById("problem_attr_sum");
        var attr_sum=attr_sum_element.value;
        attr_sum++;

        var attrs =  document.getElementById("attrs");
        var tmpObj = document.createElement("div");
        tmpObj.setAttribute("class", "attr");
        var attribute_id="attr_"+attr_sum;
        tmpObj.setAttribute("id",attribute_id);
        var content = "<input type='radio' id='problem_attr_key_"+attr_sum+"' name='attr_key' value='"+attr_sum+"'/>";
        content += "<input type='text' name='attr"+attr_sum+"_value' id='problem_attr"+attr_sum+"_value' class='input_style' size='15' value='' />";
        content += "<a href='javascript:void(0);' onclick='javascript:delete_attr("+attr_sum+");'> 删除</a>";
        tmpObj.innerHTML=content;
        attrs.appendChild(tmpObj);
        attr_sum_element.setAttribute("value",attr_sum.toString());
    }
    if(type=="more_choose"){
        var attr_sum_element=document.getElementById("problem_attr_sum");
        var attr_sum=attr_sum_element.value;
        attr_sum++;
        var content = "<input type='checkbox' id='problem_attr_key_"+attr_sum+"' name='attr"+attr_sum+"_key' value='"+attr_sum+"'/>";
        content += "<input type='text' name='attr"+attr_sum+"_value' id='problem_attr"+attr_sum+"_value' class='input_style' size='15' value='' />";
        content += "<a href='javascript:void(0);' onclick='javascript:delete_attr("+attr_sum+");'> 删除</a>";
        var attrs =  document.getElementById("attrs");
        var tmpObj = document.createElement("div");
        tmpObj.setAttribute("class", "attr");
        var attribute_id="attr_"+attr_sum;
        tmpObj.setAttribute("id",attribute_id);
        tmpObj.innerHTML=content;
        attrs.appendChild(tmpObj);
        attr_sum_element.setAttribute("value",attr_sum.toString());
    }
}

//删除选项
function delete_attr(attr_id) {
    var attrs = document.getElementById("attr_"+attr_id);
    attrs.innerHTML="";

}

function new_attr_edit(type,question_id){
    if(type=="single_choose"){
        var attrs =  document.getElementById("attrs_"+question_id);
        var inputs = attrs.getElementsByTagName("input");
        var attr_sum_element=inputs[0];
        var attr_sum=attr_sum_element.value;
        attr_sum++;
        var content = "<input type='radio' id='problem_attr_key_"+attr_sum+"' name='attr_key"+question_id+"' value='"+attr_sum+"'/>";
        content += "<input type='text' name='attr"+attr_sum+"_value"+question_id+"' id='problem_attr"+attr_sum+"_value' class='input_style' size='15' value='' />";
        content += "<a href='javascript:void(0);' onclick='javascript:delete_attr_edit("+attr_sum+","+question_id+");'> 删除</a>";
        var tmpObj = document.createElement("div");
        tmpObj.setAttribute("class", "attr");
        var attribute_id="attr_"+attr_sum+"_"+question_id;
        tmpObj.setAttribute("id",attribute_id);
        tmpObj.innerHTML=content;
        attrs.appendChild(tmpObj);
        attr_sum_element.setAttribute("value",attr_sum.toString());
    }
    if(type=="more_choose"){
        var attrs =  document.getElementById("attrs_"+question_id);
        var inputs = attrs.getElementsByTagName("input");
        var attr_sum_element=inputs[0];
        var attr_sum=attr_sum_element.value;
        attr_sum++;
        var content = "<input type='checkbox' id='problem_attr_key_"+attr_sum+"' name='attr"+attr_sum+"_key"+question_id+"' value='"+attr_sum+"'/>";
        content += "<input type='text' name='attr"+attr_sum+"_value"+question_id+"' id='problem_attr"+attr_sum+"_value' class='input_style' size='15' value='' />";
        content += "<a href='javascript:void(0);' onclick='javascript:delete_attr_edit("+attr_sum+","+question_id+");'> 删除</a>";


        var tmpObj = document.createElement("div");
        tmpObj.setAttribute("class", "attr");
        var attribute_id="attr_"+attr_sum+"_"+question_id;
        tmpObj.setAttribute("id",attribute_id);
        tmpObj.innerHTML=content;
        attrs.appendChild(tmpObj);
        attr_sum_element.setAttribute("value",attr_sum.toString());
    }
}

function delete_attr_edit(attr_id,question_id){
    var attrs = document.getElementById("attr_"+attr_id+"_"+question_id);
    attrs.innerHTML="";
}
    

