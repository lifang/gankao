
//验证  修改试卷基本信息
function edit_paper_info(form_id, button_id, pic_id){
    var paper_title=document.getElementById("edit_paper_title").value;
    if (paper_title == null || paper_title.length ==0){          
        alert("试卷标题不能为空。");        
        return false;
    }
    sumbit_form(form_id, button_id, pic_id);
}

//验证 修改模块信息
function edit_block_info(id){
    var block_title=document.getElementById("edit_block_title_"+id).value;
    if (block_title == null || block_title.length ==0){
        alert("模块标题不能为空。");
        return false;
    }
    return true;
}

//验证 编辑题目
function edit_problem_validate(problem_id){
    if($("edit_title_"+problem_id).value.replace(/<br \/>/g,"")!=null){
        var problem_title = $("edit_title_"+problem_id).value.replace(/<br \/>/g,"");
        var text_source = problem_title.replace(/^\s+/, "").replace(/ \s+$/, "");
        if(problem_title=="" || checkspace(text_source)){
            alert("题面不能为空。");
            return false;
        }
    }

    var answer_array=[];
    for(var i=1;i<=parseInt(document.getElementById("problem_attr_sum").value);i++){     //验证 选项不能为空
        if(document.getElementById("problem_attr"+i+"_value")!=null){
            var attr_value = document.getElementById("problem_attr"+i+"_value").value;
            answer_array.push(attr_value);
            if (attr_value==""){
                alert("选项不能为空。");
                return false;
            }
        }
    }

//    var answer_array_sort=answer_array.sort();
//    for(var i=0;i<answer_array.length;i++){
//        if (answer_array_sort[i]==answer_array_sort[i+1]){
//            alert("选项内容重复："+answer_array_sort[i]);
//            return false;
//        }
//    }


    if(document.getElementById("problem_answer")!=null){           //验证答案不能为空
        var problem_answer = document.getElementById("problem_answer").value;
        if (problem_answer==""){
            alert("答案不能为空。");
            return false;
        }
    }

    if(document.getElementById("problem_attr_key_1")!=null){
        var checked_num = 0;                               //验证是否选择正确答案,单选,多选都可用
        for(i=0;i<parseInt(document.getElementById("problem_attr_sum").value);i++){
            if(document.getElementById("problem_attr_key_"+(i+1))!=null && document.getElementById("problem_attr_key_"+(i+1)).checked){
                checked_num++;
            }
        }
        if (checked_num==0){
            alert("请设置正确选项。");
            return false;
        }
    }
}

function edit_colligation_validate(){
    var question_titles = document.getElementsByName("problem[description]");
    for(var i=0;i<question_titles.length;i++){
        if (question_titles[i].value.replace(/<br \/>/g,"")!=null){
            var question_title = question_titles[i].value.replace(/<br \/>/g,"");
            var text_source = question_title.replace(/^\s+/, "").replace(/ \s+$/, "");
            if(question_title=="" || checkspace(text_source)){
                alert("小题描述不能为空。");
                return false;
            }
        }
    }


    var answer_values = document.getElementsByName("problem[answer]");
    for(var i=0;i<answer_values.length;i++){
        if (answer_values[i].value!=null){
            var answer_value = answer_values[i].value;
            if(answer_value=="" || checkspace(answer_value)){
                alert("答案不能为空。");
                return false;
            }
        }
    }
    
}


//验证 新建试题
function new_problem_validate(block_id){
 
    var problem_title = $("problem_title_"+block_id).value.replace(/<br \/>/g,"");
    var text_source = problem_title.replace(/^\s+/, "").replace(/ \s+$/, "");
    if(problem_title == null  || problem_title.length == 0 || checkspace(text_source)){
        alert("题面不能为空。");
        return false;
    }

    if(document.getElementById("problem_description")!=null){           //验证小题描述不能为空
        var problem_description = document.getElementById("problem_description").value;
        if (problem_description==""||checkspace(problem_description)){
            alert("描述不能为空。");
            return false;
        }
    }


    if(document.getElementById("problem_attr1_value")!=null){
        var answer_array=new Array;
        for(var i=1;i<=parseInt(document.getElementById("problem_attr_sum").value);i++){     //验证 选项不能为空
            if(document.getElementById("problem_attr"+i+"_value")!=null){
                var attr_value = document.getElementById("problem_attr"+i+"_value").value;
                answer_array.push(attr_value);
                if (attr_value==""||checkspace(attr_value)){
                    alert("选项不能为空。");
                    return false;
                }
            }
        }
        var answer_array_sort=answer_array.sort();
        for(var i=0;i<answer_array.length;i++){
            if (answer_array_sort[i]==answer_array_sort[i+1]){
                alert("选项内容重复："+answer_array_sort[i]);
                return false;
            }
        }
    }
    
    if(document.getElementById("problem_answer")!=null){           //验证答案不能为空
        var problem_answer = document.getElementById("problem_answer").value;
        if (problem_answer==""||checkspace(problem_answer)){
            alert("答案不能为空。");
            return false;
        }
    }

    //验证是否选择正确答案,单选,多选都可用
    if(document.getElementById("problem_attr_key_1")!=null){
        var checked_num = 0;
        for(i=0;i<parseInt(document.getElementById("problem_attr_sum").value);i++){
            var index=i+1;
            if(document.getElementById("problem_attr_key_"+index).checked){
                checked_num++;
            }
        }
        if (checked_num==0){
            alert("请设置正确答案。");
            return false;
        }
    }

}

//验证  新建模块
function new_module_validate(){
    var new_module_title = document.getElementById("new_module_title").value;
    if ( new_module_title == null || new_module_title==""||checkspace(new_module_title) ){
        return false;
    }
    sumbit_form("module_form", "module_submit", "spinner_new_module");
    
}

//验证专家新建题目
function check_mavin_problem(block_id) {
    $("span_" + block_id).innerHTML = "";
    var mavin_title = $("mavin_problem_title_" + block_id).value;
    if (mavin_title != null && checkspace(mavin_title)) {
        $("span_" + block_id).innerHTML = "<font color='red'>请您填写好题目后再保存。</font>";
        return false;
    }
    if (!mavin_title.include("[[") && !mavin_title.include("{{")) {
        $("span_" + block_id).innerHTML = "<font color='red'>请您设置题点。</font>";
        return false;
    }
    if ((mavin_title.include("[[") && !mavin_title.include("]]"))||(mavin_title.include("{{") && !mavin_title.include("}}"))) {
        $("span_" + block_id).innerHTML = "<font color='red'>您的提点格式不正确，提点格式为[[提点内容]]。</font>";
        return false;
    }
    if (!mavin_title.include("[(")) {
        $("span_" + block_id).innerHTML = "<font color='red'>请您设置分值。</font>";
        return false;
    }
    if (mavin_title.include("[(") && !mavin_title.include(")]")) {
        $("span_" + block_id).innerHTML = "<font color='red'>您的分值格式不正确，提点格式为[(分数)]。</font>";
        return false;
    }
    if (!mavin_title.include("[{")) {
        $("span_" + block_id).innerHTML = "<font color='red'>请您设置解析。</font>";
        return false;
    }
    if (mavin_title.include("[{") && !mavin_title.include("}]")) {
        $("span_" + block_id).innerHTML = "<font color='red'>您的解析格式不正确，提点格式为[{解析}]。</font>";
        return false;
    }
    sumbit_form("problem_form", "problem_submit", "spinner_"+block_id);
}