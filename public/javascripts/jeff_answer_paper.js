
var step=parseInt($("practice_type").value)-2;       //记录用户当前的进度
var last_choose_question_id=0;   //记录当前选中的小题id
var last_open_problem_id=0;    //记录最后一次打开的题目（综合题2，显示说明用）
var do_examination_id=document.getElementById("examination_id").value;
if(getCookie("do_examination_"+do_examination_id)!=null){
    last_open_problem_id=getCookie("do_examination_"+do_examination_id);     //通过cookie记录这场考试最后一道题目的id
}
var load_switch=0;   //页面载入前，置0；页面载入后，置1。该变量目前只在综合训练5中控制流程。


var check_answer=0;  //判断是否检查
var correct_sum=0;  //统计正确的题数

var answer=new Array;
if($("show_answer")!=null&&$("show_answer").value!=""){
    answer=$("show_answer").value.replace(/(")/g, "").split("|-|-|");
}
var question_result_color=0; //记录题目的颜色。默认为0；1为答对；2错误;
//加载综合训练
function load_paper(practice_type) {
    setTimeout(function(){
        create_paper(practice_type);
        load_switch=1;   //页面载入完成，设置load_switch=1 目前只有第五类综合训练使用到，控制程序流程有用。
    }, 500);
}

//创建综合训练
function create_paper(practice_type) {
    $("paper_id").value = papers.paper.id;
    //    $("total_num").innerHTML = papers.paper.total_num;
    if (papers.paper.blocks != undefined && papers.paper.blocks.block != undefined) {
        var blocks = papers.paper.blocks.block;
        var bocks_div = $("blocks");
        if (tof(blocks) == "array") {
            //            for (var i=0; i<blocks.size();i++) {
            //                create_block(bocks_div, blocks[i],practice_type);
            //            }
            create_block(bocks_div, blocks[step],practice_type);
        } else {
            create_block(bocks_div, blocks,practice_type);
        }
    }
//load_scroll();
}

//添加试卷块
var question_num = 1;   //根据提点显示导航
var block_block_flag = 0;   //记录打开的模块
function create_block(bocks_div, block,practice_type) {
    //添加block的div
    if ($("block_ids") != null && $("block_ids").innerHTML != "") {
        $("block_ids").innerHTML = $("block_ids").innerHTML + "," + block.id;
    } else {
        $("block_ids").innerHTML = block.id;
    }
    var ul = create_element("div", null, "block_" + block.id, "tb_content", null, "innerHTML");
    bocks_div.appendChild(ul);
    var navigation_div = create_element("div",null,"paper_navigation","task3_li",null,null);
    navigation_div.style.display="none";
    if(practice_type=="4"||practice_type=="5"||practice_type=="6"){
        ul.innerHTML+="<div class='space20'></div>";
    }
    ul.appendChild(navigation_div);
    if(practice_type=="3"){
        ul.innerHTML+="<div class='space20'></div>";
    }
    var block_nav_div = create_element("ul", null,null, null, null);
    navigation_div.appendChild(block_nav_div);
    var fill_blank=ul.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    //判断problem的存在
    if (block.problems != undefined && block.problems.problem != undefined) {
        var problems = block.problems.problem;
        if (tof(problems) == "array") {
            for (var j=0; j<problems.size(); j++) {
                if(practice_type=="2"){
                    ul.innerHTML+="<div class='space20'></div>"
                }
                create_problem(ul, problems[j], block_nav_div,practice_type);
            }
        } else {
            if(practice_type=="2"){
                ul.innerHTML+="<div class='space20'></div>"
            }
            create_problem(ul, problems, block_nav_div,practice_type);
        }
        var fill_blank=ul.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
        block_nav_div.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    }
}

//生成第三类综合训练的拖动框
function create_question_navigation(block_nav_div, question, innerHTML, problem_id,practice_type) {
    if(practice_type=="4"||practice_type=="5"){
        var que_attrs = question.questionattrs.split(";-;");
        $("paper_navigation").style.display="block";
        que_attrs = que_attrs.sort(sortRandom);
        for (var i=0; i<que_attrs.length; i++) {
            var question_nav_div = create_element("li", null, "question_nav_"+question.id, null, null, "innerHTML");
            question_nav_div.className = "problem_nav_div";
            if (que_attrs[i] != null && que_attrs[i] != "") {
                var store_id="question_"+question.id+"_draggable_"+(i+1);
                var attr = create_element("span", null,null, null, null, "innerHTML");
                question_nav_div.appendChild(attr);
                var drag_span = create_element("span", null, store_id, null, null, "innerHTML");
                drag_span.style.cursor='Move';
                drag_span.innerHTML +=que_attrs[i];
                attr.appendChild(drag_span);
                block_nav_div.appendChild(question_nav_div);
                new Draggable(store_id,{
                    revert:true
                });
            }
        }  //创建可拖动的选项。
    }
}

//控制第二类综合训练题的提示框
function practice2_list(problem_id){
    if(last_open_problem_id==0){
        $("practice2_list_"+problem_id).slideDown();
    }
    if(last_open_problem_id!=0){
        if(last_open_problem_id!=problem_id){
            $("practice2_list_"+problem_id).slideDown();
            $("practice2_list_"+last_open_problem_id).hide()
        }else{
            $("practice2_list_"+problem_id).slideUp();
            last_open_problem_id=0;
            return 0;
        }
    }
    last_open_problem_id=problem_id;
}


//添加problem
function create_problem(ul, problem, block_nav_div,practice_type) {
    var task_con_div=null;
    var parent_div = create_element("div", null, "full_problem_" + problem.id, null, null, "innerHTML");
    var question_id_input = create_element("input", "question_ids", "question_ids_" + problem.id, null, "hidden", "value");
    var parent_div_str = "<input type='hidden' name='problem_"+ problem.id +"' id='problem_"+ problem.id +"' value='"+ problem.id +"'/>";
    var problem_title=problem.title.replace("audio_play('x')","audio_play("+problem.id+")").replace("id=\"audio_x\"","id='audio_"+problem.id+"'").replace("id=\"audio_control_x\"","id='audio_control_"+problem.id+"'").replace(/problem_x_dropplace/g,"problem_"+problem.id+"_dropplace").replace(/problem_x_writefont/g,"problem_"+problem.id+"_writefont")
    if(practice_type=="3"){
        parent_div_str += "<div class='task_con'>";
        parent_div_str += "<div class='play'><div class='play_btn'><a href='javascript:void(0);' onclick='javascript:audio_play("+problem.id+");'><img id='practice2_audio_control_"+problem.id+"' src='/images/paper/play_icon.png'></a></div><a  href='javascript:void(0);' class='explain_btn_task2' onclick=\"javascript:practice2_list("+problem.id+");\" ></a></div>";
        parent_div_str += "<div class='tb_con_list' id='practice2_list_"+problem.id+"'>"+problem_title+"<br/></div>";
        parent_div_str +="</div>";
    }else{
        if(practice_type=="6"){
            var task_con_div = create_element("div", null, "task_con_" + problem.id, "task_con", null, "innerHTML");
            parent_div_str += "<div class='play'><div class='play_btn'><a href='javascript:void(0);' onclick='javascript:audio_play("+problem.id+");'><img id='practice2_audio_control_"+problem.id+"' src='/images/paper/play_icon.png'></a></div></div>";
            parent_div_str += "<div style='display:none;' >"+problem_title+"</div>";
            parent_div_str += "<input type='hidden' id='practice5_list_"+problem.id+"' value=\""+problem_title.replace(/<[^{><}]*>/g, "")+"\" />";
        }else{
            if(practice_type=="4"||practice_type=="5"){
                parent_div_str += "<div class='task_con'><p>"+ problem_title + "   </p></div>";
            }else{
                parent_div_str += "<div class='play'>";
                if(problem.title.indexOf("audio_play('x')")>0){
                    parent_div_str +="<div class='play_btn'><a href='javascript:void(0);' onclick='javascript:audio_play("+problem.id+");'><img id='practice2_audio_control_"+problem.id+"' src='/images/paper/play_icon.png'></a></div>"
                    parent_div_str += "<div style='display:none;' >"+problem_title+"</div>";
                }
                parent_div_str += "<div class='tishi'>"+ problem_title.replace(/<[^{><}]*>/g, "") + "</div><div class='clear'></div></div>"
            }
        }
    }
    if(task_con_div!=null){
        parent_div.appendChild(task_con_div);
        task_con_div.innerHTML = parent_div_str;
    }else{
        parent_div.innerHTML = parent_div_str;
    }
    ul.appendChild(parent_div);
    if(practice_type=="3"){
        if($("audio_control_"+problem.id)){
            $("audio_control_"+problem.id).style.display="none";
        }
        $("practice2_list_"+problem.id).hide();
    }
    if (problem.questions != undefined && problem.questions.question != undefined) {
        var questions = problem.questions.question;
        if (tof(questions) == "array") {
            for (var j=0; j<questions.size(); j++) {
                create_question_navigation(block_nav_div, questions[j], question_num, problem.id,practice_type);
                create_question(problem_title,problem.id, question_id_input, parent_div, questions[j],practice_type,task_con_div);
                question_num ++ ;
            }
        } else {
            create_question_navigation(block_nav_div, questions, question_num, problem.id,practice_type);
            create_question(problem_title,problem.id, question_id_input, parent_div, questions,practice_type,task_con_div);
            question_num ++ ;
        }
    }


    parent_div.appendChild(question_id_input);
    var is_answer_input = create_element("input", "is_answer", "is_answer_" + problem.id, null, "hidden", "value");
    parent_div.appendChild(is_answer_input);
    var is_sure_input = create_element("input", "is_sure", "is_sure_" + problem.id, null, "hidden", "value");
    parent_div.appendChild(is_sure_input);
    //add_save_button(parent_div, problem.id);
    $("problem_ids").value += "" + problem.id + ",";
    if (answer_hash != null) {
        load_un_sure_question(problem.id);
        is_problem_answer(problem.id,practice_type);
    }
}


//增加提点保存按钮
function add_que_save_button(parent_div, question_id, problem_id,practice_type,task_con_div) {
    var buttons_div = create_element("div", null, "save_button_" + question_id, "p_question_btn", null, "innerHTML");
    buttons_div.innerHTML = "<input type='button' name='question_submit' class='save' onclick='javascript:generate_question_answer(\""+ question_id +"\", \""+problem_id+"\", \"1\","+practice_type+");'/>";
    buttons_div.style.display = "none";
    if(practice_type=="6"){
        task_con_div.appendChild(buttons_div);
    }else{
        parent_div.appendChild(buttons_div);
    }
}

//显示提点按钮
function show_que_save_button(question_id) {
    var save_button = $("save_button_" + question_id);
    if (save_button != null && save_button.style.display == "none") {
        save_button.style.display = "block";
    }
}

//添加question所需div
function create_question(problem_title,problem_id, question_id_input, parent_div, question,practice_type,task_con_div) {
    $("all_question_ids").value += "" + question.id + ",";
    question_id_input.value += "" + question.id + ",";
    if(practice_type=="4"||practice_type=="5"||practice_type=="6"){
        var que_div = create_element("div", null, "question_" + question.id, null, null, "innerHTML");
    }else{
        var que_div = create_element("div", null, "question_" + question.id, "task_con", null, "innerHTML");
    }
    if (question.description != undefined &&question.description !=""&&practice_type!="4"&&practice_type!="5") {
        que_div.innerHTML += "<div class='question_title'> " + question.description+"</div>";
    }
    que_div.innerHTML += "<input type='hidden' name='question_type' id='question_type_"+ question.id +"' value='"+ question.correct_type +"'/>";
    parent_div.appendChild(que_div);
    //根据problem是否确定来判断question是否确定
    var question_is_sure = create_element("input", "question_sure", "question_sure_" + question.id, null, "hidden", "value");
    parent_div.appendChild(question_is_sure);
    create_single_question(problem_title,problem_id, que_div, question,practice_type,task_con_div);
    add_que_save_button(que_div, question.id, problem_id,practice_type,task_con_div);
}

var sortRandom = function (){
    return Math.random()>0.5;
}

function create_single_question(problem_title,problem_id, que_div_conlist, question,practice_type,task_con_div) {
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_div_ul=create_element("ul", null, null, "chooseQuestion", null, "innerHTML");
        que_div_conlist.appendChild(que_div_ul);
        var que_attrs = question.questionattrs.split(";-;");
        if(practice_type=="4"||practice_type=="5"){
            var place_num = 1;
            while(problem_title.indexOf("problem_"+problem_id+"_dropplace_"+place_num)>=0){
                var store_id="problem_"+problem_id+"_dropplace_"+place_num;
                $(store_id).style.cursor='Move';
                $(store_id).setAttribute("class","task_span");
                Droppables.add(store_id, {
                    onDrop:function(element,store_id){
                        $(store_id).innerHTML=element.innerHTML;
                        show_que_save_button(question.id);
                        var this_answer=""
                        for(i=1;i<place_num;i++){
                            this_answer +=$("problem_"+problem_id+"_dropplace_"+i).innerHTML;
                            if(i<place_num-1){
                                this_answer +=";|;";
                            }
                        }
                        $("answer_"+question.id).value=this_answer;
                        $("is_answer_"+problem_id).value="1";
                    }
                });
                place_num ++;
            } //检测并设置题目描述中答案落点位置。  提示，题目描述中请按要求设置落点，如 <font color="green" id="problem_x_dropplace_1">_________</font> 和 <font color="green" id="problem_x_dropplace_2">_________</font>
        //选词填空题，为只有一个多选题的综合题。 多选题答案的顺序要与描述中落点位置对应起来。
        } else {
            for (var i=0; i<que_attrs.length; i++) {
                if (que_attrs[i] != null && que_attrs[i] != "") {
                    var attr = create_element("li", null, null, null, null, "innerHTML");
                    que_div_ul.appendChild(attr);
                    if (question.correct_type == "0") {
                        attr.innerHTML += "<input type='hidden' id='question_"+question.id+"_type' value='0' />";
                        if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == que_attrs[i]) {
                            attr.innerHTML += "<input type='radio'  name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />";
                            if(check_answer==1){
                                if(answer!=null&&answer.length>0&&answer[question_num-1]==que_attrs[i]){
                                    attr.style.background="#96AE89";
                                    correct_sum++;
                                }else{
                                    attr.style.background="#D1A39B";
                                }
                            }
                        } else {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        }
                        attr.innerHTML += "<label> &nbsp;"+ que_attrs[i] +"</label>";
                    } else if (question.correct_type == "1") {
                        attr.innerHTML += "<input type='hidden' id='question_"+question.id+"_type' value='1' />";
                        var true_false=false;
                        if(check_answer==1){
                            if(answer!=null && answer.length>0 && answer_hash != null &&  answer_hash[question.id] != null){
                                var this_answer=answer[question_num-1].split(";|;");
                                if(this_answer.join(";|;")==answer_hash[question.id][0]&&i==que_attrs.length-1){
                                    correct_sum++;
                                }

                                for(var true_false_n=0;true_false_n<this_answer.length;true_false_n++){
                                    if(this_answer[true_false_n]==que_attrs[i]){
                                        true_false=true;
                                    }
                                }
                            }
                        }
                        if (answer_hash != null &&  answer_hash[question.id] != null && answer_hash[question.id][0].split(";|;").include(que_attrs[i])) {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                            if(check_answer==1){
                                if(true_false){
                                    attr.style.background="#96AE89";
                                }else{
                                    attr.style.background="#D1A39B";
                                }
                            }
                        } else {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                            if(check_answer==1){
                                if(true_false){
                                    attr.style.background="#D1A39B";
                                }
                            }
                        }
                        attr.innerHTML += "<label> &nbsp;"+ que_attrs[i] +"</label>";
                    }
                }
            }
        }
    }else {
        if (question.correct_type == "2") {
            var que_div_ul=create_element("ul", null, null, "chooseQuestion", null, "innerHTML");
            que_div_conlist.appendChild(que_div_ul);
            var attr1 = create_element("li", null, null, null, null, "innerHTML");
            que_div_ul.appendChild(attr1);
            attr1.innerHTML += "<input type='hidden' id='question_"+question.id+"_type' value='2' />";
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == "1") {
                if(check_answer==1){
                    if(answer!=null&&answer.length>0&&answer[question_num-1]=="1"){
                        attr1.style.background="#96AE89";
                        correct_sum++;
                    }else{
                        attr1.style.background="#D1A39B";
                    }
                }
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' /> &nbsp;对/是&nbsp;&nbsp;";
            } else {
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' onclick='javascript:show_que_save_button(\""+question.id+"\")' /> &nbsp;对/是&nbsp;&nbsp;";
            }
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == "0") {
                if(check_answer==1){
                    if(answer!=null&&answer.length>0&&answer[question_num-1]=="0"){
                        attr1.style.background="#96AE89";
                        correct_sum++;
                    }else{
                        attr1.style.background="#D1A39B";
                    }
                }
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' /> &nbsp;错/否&nbsp;&nbsp;";
            } else {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' onclick='javascript:show_que_save_button(\""+question.id+"\")'/> &nbsp;错/否&nbsp;&nbsp;";
            }
        } else {
            var attr1 = create_element("div", null, null, null, null, "innerHTML");
            que_div_conlist.appendChild(attr1);
            if (answer_hash != null && answer_hash[question.id] != null&&answer_hash[question.id][0].replace(/\n/g, "")!="") {
                if(practice_type=="6"){
                    var tishi =$("practice5_list_"+problem_id).value;
                    var task_area_div=create_element("div", null, null, "task_textarea", null, "innerHTML");
                    task_con_div.appendChild(task_area_div);
                    task_area_div.innerHTML += "<textarea  id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'  onblur='if(this.value.length==0){this.value=\"提示： "+tishi+"\";}' >"+ answer_hash[question.id][0] +"</textarea>";
                }else{
                    if (question.correct_type == "3") {
                        attr1.innerHTML += "<input type='text' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' value='"+ answer_hash[question.id][0] +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")' ></input>";
                    }else{
                        attr1.innerHTML += "<textarea style='width: 99%; height: 100px; margin: 2px 2px;' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")' >"+ answer_hash[question.id][0] +"</textarea>";
                    }
                }
                if(check_answer==1){
                    if(answer!=null&&answer.length>0&&answer_hash[question.id][0]==answer[question_num-1]){
                        if(practice_type=="6"){
                            task_area_div.style.background="#96AE89";
                        }else{
                            attr1.style.background="#96AE89";
                        }
                        correct_sum++;
                    }else{
                        if(practice_type=="6"){
                            task_area_div.style.background="#D1A39B";
                        }else{
                            attr1.style.background="#D1A39B";
                        }
                    }
                }
            } else {
                if(practice_type=="6"){
                    var tishi =$("practice5_list_"+problem_id).value;
                    var task_area_div=create_element("div", null, null, "task_textarea", null, "innerHTML");
                    task_con_div.appendChild(task_area_div);
                    task_area_div.innerHTML += "<textarea  id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onclick='this.focus();this.select();' onfocus='javascript:show_que_save_button(\""+question.id+"\");'  onblur='if(this.value.length==0){this.value=\"提示： "+tishi+"\";}' >提示："+tishi +"</textarea>";
                }else{
                    if (question.correct_type == "3") {
                        attr1.innerHTML += "<input type='text' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")' ></input>";
                    }else{
                        attr1.innerHTML += "<textarea style='width: 99%; height: 100px; margin: 2px 2px;' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\");'></textarea>";
                    }
                }
            }
        }
    }
    var answer_input = create_element("input", "answer_" + question.id, "answer_" + question.id, null, "hidden", "value");
    if (answer_hash != null && answer_hash[question.id] != null) {
        answer_input.value = answer_hash[question.id][0];
        if(practice_type=="4"||practice_type=="5"){
            var question_array = answer_hash[question.id][0].split(";|;");
            if(check_answer==0){
                for(var i=0;i<question_array.length;i++){
                    $("problem_"+problem_id+"_dropplace_"+(i+1)).innerHTML=question_array[i];
                }
            }else{
                var this_answer_array = answer[question_num-1].split(";|;");
                if(this_answer_array.join(",")==question_array.join(",")){
                    correct_sum++;
                }
                for(var i=0;i<question_array.length;i++){
                    if(question_array[i]==this_answer_array[i]){
                        $("problem_"+problem_id+"_dropplace_"+(i+1)).innerHTML=question_array[i];
                        $("problem_"+problem_id+"_dropplace_"+(i+1)).setAttribute("class", "task_span correctRight_bg");
                    }else{
                        $("problem_"+problem_id+"_dropplace_"+(i+1)).innerHTML=question_array[i];
                        $("problem_"+problem_id+"_dropplace_"+(i+1)).setAttribute("class", "task_span red_bg");
                    }
                }
            }
        }
    }
    que_div_conlist.appendChild(answer_input);
}

//创建input
function create_element(element, name, id, class_name, type, ele_flag) {
    var ele = document.createElement("" + element);
    if (name != null)
        ele.name = name;
    if (id != null)
        ele.id = id;
    if (class_name != null)
        ele.className = class_name;
    if (type != null)
        ele.type = type;
    if (ele_flag == "innerHTML") {
        ele.innerHTML = "";
    } else {
        ele.value = "";
    }
    return ele;
}


//用来判断获取数据的类型
function tof(val) {
    var t;
    switch(val) {
        case null:
            t = "null";
            break;
        case undefined:
            t = "undefined";
            break;
        default:
            t = Object.prototype.toString.call(val).match(/object\s(\w+)/)[1];
            break;
    }
    return  t.toLowerCase();
}

//用来返回题目中所有的提点是否已经回答
function is_problem_answer(problem_id,practice_type) {
    var answer_flag = "";
    var question_ids = $("question_ids_" + problem_id).value;
    if (question_ids != "") {
        var ids = question_ids.split(",");
        var is_answer_num = 0;
        if(practice_type=="2"||practice_type=="3"||practice_type=="6"){
            for (var i=0; i<ids.length-1; i++) {
                var question_div = $("question_" + ids[i]);
                if (question_div != null) {
                    var is_answer = question_value(ids[i],practice_type);
                    if (is_answer) {
                        is_answer_num++ ;
                    }
                }
            }
            if (is_answer_num != 0) {
                if (is_answer_num == (ids.length-1)) {
                    answer_flag = "all";
                } else {
                    answer_flag = "href";
                }
            } else {
                answer_flag = "none";
            }
        }else{
            if($("is_answer_" + problem_id).value = "1"){ //第三类综合题经过这里
                return "all";
            }
        }
        if (answer_flag == "all") {
            $("is_answer_" + problem_id).value = "1";
        } else {
            $("is_answer_" + problem_id).value = "";
        }
        return answer_flag;
    } 
}

//用来返回提点是否已经回答
function generate_question_answer(question_id, problem_id, is_sure,practice_type) {
    $("question_sure_" + question_id).value = "" + is_sure;
    is_problem_answer(problem_id,practice_type);
    save_question(question_id, is_sure);
    $("save_button_" + question_id).style.display = "none";  
}

//使用本地存储保存提点内容
function save_question(question_id, is_sure) {
    var paper_id = $("paper_id").value;
    var examination_id = $("examination_id").value;
    var answer = $("answer_" + question_id);
    if (answer != null && !checkspace(answer.value)) {
        remove_answer(question_id, getCookie('user_id'), paper_id, examination_id);
        add_answer(question_id, getCookie('user_id'), paper_id, examination_id, answer.value, is_sure);
        answer_hash[question_id] = new Array(answer.value, is_sure);
    }
}

//返回提点是否确定，以及颜色
function load_un_sure_question(problem_id) {
    var question_ids = $("question_ids_" + problem_id).value;
    if (question_ids != "") {
        var ids = question_ids.split(",");
        for (var i=0; i<ids.length-1; i++) {
            if (answer_hash != null && answer_hash[ids[i]] != null) {
                if(parseInt(answer_hash[ids[i]][1]) == 1){
                    $("question_sure_" + ids[i]).value = "1";
                } else {
                    $("question_sure_" + ids[i]).value = "0";
                }
            }
        }
    }
}

//用来返回每个提点是否已经回答
function question_value(question_id,practice_type) {
    //第三类综合题没有经过这个方法
    var is_answer = false;
    $("answer_" + question_id).value = "";
    var correct_type = $("question_type_" + question_id).value;
    if (correct_type == "0" || correct_type == "1" || correct_type == "2") {
        var attr = document.getElementsByName("question_attr_" + question_id);
        if (attr != null) {
            for (var i=0; i<attr.length; i++) {
                if (attr[i].checked == true) {
                    if ($("answer_" + question_id).value == "") {
                        $("answer_" + question_id).value = attr[i].value;
                    } else {
                        $("answer_" + question_id).value += ";|;" + attr[i].value;
                    }
                    is_answer = true;
                }
            }
        }
    }else {
        var answer = $("question_answer_" + question_id);
        if (answer != null && !checkspace(answer.value)) {
            is_answer = true;
            $("answer_" + question_id).value = answer.value;
        }
    }
    return is_answer;
}

//提交试卷之前判断试卷是否已经全部答对
function generate_result_paper(paper_id,examination_id,practice_type) {
    if(playing>0){
        var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
        flash_div.innerHTML = "<p>检测到音频正在播放中...请先停止</p>";
        document.body.appendChild(flash_div);
        show_flash_div();
        return false;
    }
    var all_question_ids = $("all_question_ids");
    if (all_question_ids != null && all_question_ids.value == "") {
        return true;
    }  //没有任何小题，第二类题型触发
    
    if (all_question_ids != null && all_question_ids.value != "") {
        var question_id_array=all_question_ids.value.split(",");
        var question_sum = question_id_array.length-1;
        correct_sum=0;
        for(var index=0;index<question_sum;index++){
            if($("answer_"+question_id_array[index])!=null&&$("answer_"+question_id_array[index]).value!=""&&$("answer_"+question_id_array[index]).value==answer[index]){
                correct_sum++;
            }
        //            var answer_hash = new Hash();
        //            answer_hash[question_id_array[index]]=$("answer_"+question_id_array[index]).value;
        }
        if(correct_sum==question_sum){
            return true;
        }
        question_num = 1;
        check_answer=1;
        correct_sum=0;
        //    load_answer(paper_id,examination_id);
        $("all_question_ids").value="";
        $("problem_ids").value="";
        $("block_ids").value="";
        $("paper_navigation").innerHTML="";
        $("blocks").innerHTML="";
        playing=0;
        create_paper(practice_type);

    }
    return false;
}


function local_storage_answer() {
    var all_question_ids = $("all_question_ids").value;
    if (all_question_ids != null && all_question_ids != "") {
        var question_ids = all_question_ids.split(",");
        if (question_ids.length != 0) {
            var arr = new Array();
            for (var j=0; j<question_ids.length; j++) {
                var ans = $("answer_" + question_ids[j]);
                if (ans != null && ans.value != "") {
                    arr.push(question_ids[j]);
                    arr.push(ans.value);
                    arr.push($("question_sure_" + question_ids[j]).value);
                }
            }
            add_to_db(arr);
        }
    }
}

//load用户已经答完的答案
function load_answer(paper_id, examination_id) {
    if(window.openDatabase){
        load_local_save(paper_id, examination_id);
    }
}

//load本地存储的答案
function load_local_save(paper_id, examination_id) {
    if (paper_id != "" && examination_id != "" && getCookie('user_id') != "") {
        list_answer(getCookie('user_id'), paper_id, examination_id);
    }
}
