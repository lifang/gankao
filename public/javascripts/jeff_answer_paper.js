
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
    answer=$("show_answer").value.replace(/(")/g, "").split(", ");
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
    $("total_num").innerHTML = papers.paper.total_num;
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
    if(block.base_info.description!=null){
        $("jiexi_tab_p").innerHTML = block.base_info.description;
    }
    var block_div = create_element("div", null, "block_" + block.id, null, null, "innerHTML");
    bocks_div.appendChild(block_div);
    var ul_div = create_element("div", null, "block_ul_" + block.id, null, null, "innerHTML");
    block_div.appendChild(ul_div);
    var ul = create_element("div", null, "ul_" + block.id, "tb_scroll height507", null, "innerHTML");

    ul_div.appendChild(ul);
    //试卷导航展开部分
    var navigation_div = $("paper_navigation");
    //试卷导航隐藏部分
    var task3_li_class=create_element("div",null,"block_nav_"+block.id,"task3_li",null, null)
    navigation_div.appendChild(task3_li_class);
    var block_nav_div = create_element("ul", null,null, null, null);
    task3_li_class.appendChild(block_nav_div);
    //判断problem的存在
    if (block.problems != undefined && block.problems.problem != undefined) {
        var problems = block.problems.problem;
        if (tof(problems) == "array") {
            for (var j=0; j<problems.size(); j++) {
                create_problem(ul, problems[j], block_nav_div,practice_type);
            }
        } else {
            //create_problem_navigation(block_nav_div, problems, "1");
            create_problem(ul, problems, block_nav_div,practice_type);
        }
        var fill_blank=ul.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
        //        fill_blank.innerHTML+="<div style='height:450px;'></div>";
        block_nav_div.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    }
}

//打开模块
function open_nav(block_id, block_time) {
    var block_ids = $("block_ids");
    if (block_ids != null && block_ids.innerHTML != "") {
        var b_ids = block_ids.innerHTML.split(",");
        if (b_ids != null) {
            for (var i=0; i<b_ids.length; i++) {
                $("block_nav_" + b_ids[i]).style.display = "none";
                $("block_hidden_nav_" + b_ids[i]).style.display = "block";
                $("block_" + b_ids[i]).style.display = "none";
            }
        }
    }
    if (block_time != null && block_time != "" && block_time != "0") {
        update_block_time(block_id);
    } else {
        $("block_nav_" + block_id).style.display = "block";
        $("block_hidden_nav_" + block_id).style.display = "none";
        $("block_" + block_id).style.display = "block";
    }
}

// 定时考试模块，记录模块的开始考试时间
function update_block_time(block_id) {
    new Ajax.Updater("remote_div", "/user/examinations/"+ block_id +"/start_fixup_time",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            start_fix_time(block_id)
        },
        parameters:"authenticity_token=" + encodeURIComponent('BgLpQ3SADBr4tuiYZOJeoOvY4VOHogJvqQEpMwYVBM4=')
    });
    return false;
}

//模块定时完成
function start_fix_time(block_id) {
    var fixup_time_start = $("remote_div").innerHTML;
    var fixup_time_end = "00:00:00:00";
    if (fixup_time_start == fixup_time_end) {
        alert("当前部分答题时间固定，答题时间已过。");
    } else {
        load_fix_time = window.setInterval("local_fixup_time('"+ block_id +"', '"+ fixup_time_start +"', '"+ fixup_time_end +"')", 500);
    }
}

function local_fixup_time(block_id, fixup_time_start, fixup_time_end) {
    if (fixup_time_start == fixup_time_end) {
        local_storage_answer();
        window.clearInterval(load_fix_time);
        $("fix_time_div_" + block_id).innerHTML = "您这部分答案已经提交。"; 
        return;
    }
    var hms = new String(fixup_time_start).split(":");
    var ms = new Number(hms[3]);
    var s = new Number(hms[2]);
    var m = new Number(hms[1]);
    var h = new Number(hms[0]);

    ms -= 10;
    if (ms < 0) {
        ms = 90;
        s -= 1;
        if (s < 0) {
            s = 59;
            m -= 1;
        }
        if (m < 0) {
            m = 59;
            h -= 1;
        }
    }

    var mss = ms < 10 ? ("0" + ms) : ms;
    var ss = s < 10 ? ("0" + s) : s;
    var sm = m < 10 ? ("0" + m) : m;
    var sh = h < 10 ? ("0" + h) : h;

    fixup_time_start = sh + ":" + sm + ":" + ss + ":" + mss;
    $("fix_time_div_" + block_id).innerHTML = "剩余时间：" + sh + ":" + sm + ":" + ss;

    // 清除上一次的定时器
    window.clearInterval(load_fix_time);
    // 启动新的定时器
    load_fix_time = window.setInterval("local_fixup_time('"+ block_id +"', '"+ fixup_time_start +"', '"+ fixup_time_end +"')", 100);
}

//生成第三类综合训练的拖动框和显示答案的提点框
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
                drag_span.style.display='inline-block';
                drag_span.style.height='20px';
                drag_span.style.width='50px';
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

function choose_problem(question_id,problem_id){
    if(question_id!=null){
        $("question_nav_"+question_id).setAttribute("class", "dropOver");
        if(last_choose_question_id!=0&&last_choose_question_id!=question_id){
            $("question_nav_"+last_choose_question_id).removeAttribute("class");
        }
        last_choose_question_id=question_id;
    }else{
        $("problem_nav_"+problem_id).setAttribute("class", "dropOver");
        if(last_choose_question_id!=0&&last_choose_question_id!=problem_id){
            $("problem_nav_"+last_choose_question_id).removeAttribute("class");
        }
        last_choose_question_id=problem_id;
    }
}

//取得点击的题点的高度
function get_question_height(question_id, problem_id) {
    var p_height = 0;
    var problem_ids = $("problem_ids").value;
    if (problem_ids != null) {
        var p_ids = problem_ids.split(",");
        if (p_ids != null) {
            for (var i=0; i<p_ids.length; i++) {
                if (p_ids[i] == problem_id) {
                    break;
                } else {
                    if ($("li_" + p_ids[i]) != null) {
                        p_height += $("li_" + p_ids[i]).offsetHeight;
                    }
                }
            }
        }
    }
    var question_ids = $("question_ids_" + problem_id).value;
    if (question_ids != null) {
        var q_ids = question_ids.split(",");
        if (q_ids != null) {
            for (var j=0; j<q_ids.length; j++) {
                if (q_ids[j] == question_id) {
                    break;
                } else {
                    if ($("question_" + q_ids[j]) != null) {
                        p_height += $("question_" + q_ids[j]).offsetHeight;
                    }
                }
            }
        }
    }
    window.scrollTo(100, p_height+200);
}

//添加problem
function create_problem(ul, problem, block_nav_div,practice_type) {
    var parent_div = create_element("div", null, "full_problem_" + problem.id, null, null, "innerHTML");
    var question_id_input = create_element("input", "question_ids", "question_ids_" + problem.id, null, "hidden", "value");
    var parent_div_str = "<input type='hidden' name='problem_"+ problem.id +"' id='problem_"+ problem.id +"' value='"+ problem.id +"'/>";
    if(practice_type=="3"){
        parent_div_str += "<div class='task3_con'>";
        parent_div_str += "<div class='play'><div class='play_btn'><a href='javascript:void(0);' onclick='javascript:audio_play("+problem.id+");'><img id='practice2_audio_control_"+problem.id+"' src='/images/paper/play_icon.png'></a></div><a  href='javascript:void(0);' class='explain_btn_task2' onclick=\"javascript:practice2_list("+problem.id+");\" ></a></div>";
        parent_div_str += "<div class='tb_con_list' id='practice2_list_"+problem.id+"'>"+problem.title+"<br/></div>";
        parent_div_str +="</div>";
    }else{
        if(practice_type=="6"){
            parent_div_str += "<div class='task3_con'>";
            parent_div_str += "<div class='play'><div class='play_btn'><a href='javascript:void(0);' onclick='javascript:audio_play("+problem.id+");'><img id='practice2_audio_control_"+problem.id+"' src='/images/paper/play_icon.png'></a></div></div>";
            parent_div_str += "<div style='display:none;' >"+problem.title+"</div>";
            parent_div_str += "<input type='hidden' id='practice5_list_"+problem.id+"' value=\""+problem.title.replace(/<[^{><}]*>/g, "")+"\" />";
            //    字符串解析错误。
            parent_div_str += "</div>";
        }else{
            parent_div_str += "<div class='task3_con'><p>"+ problem.title + "   </p></div>";
        }
    }
    parent_div.innerHTML = parent_div_str;
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
                create_question(problem.title,problem.id, question_id_input, parent_div, questions[j],practice_type);
                question_num ++ ;
            }
        } else {
            create_question_navigation(block_nav_div, questions, question_num, problem.id,practice_type);
            create_question(problem.title,problem.id, question_id_input, parent_div, questions,practice_type);
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
        //load_un_sure_problem(problem.id);
        //load_problem_color(problem.id);
        alreay_answer_que_num();
    // answer_hash = null;
    }
//alert(parent_div.innerHTML);
}


//增加提点保存和不确定按钮
function add_que_save_button(parent_div, question_id, problem_id,practice_type) {
    var buttons_div = create_element("div", null, "save_button_" + question_id, "p_question_btn", null, "innerHTML");
    buttons_div.innerHTML = "<input type='button' name='question_submit' class='save' onclick='javascript:generate_question_answer(\""+ question_id +"\", \""+problem_id+"\", \"1\","+practice_type+");'/>";
    buttons_div.style.display = "none";
    parent_div.appendChild(buttons_div);
}

//显示提点按钮
function show_que_save_button(question_id) {
    var save_button = $("save_button_" + question_id);
    if (save_button != null && save_button.style.display == "none") {
        save_button.style.display = "block";
    }
}

//添加question所需div
function create_question(problem_title,problem_id, question_id_input, parent_div, question,practice_type) {

    $("all_question_ids").value += "" + question.id + ",";
    question_id_input.value += "" + question.id + ",";
    var que_div = create_element("div", null, "question_" + question.id, "tb_content", null, "innerHTML");
    if (question.description != undefined &&question.description !=""&&practice_type!="4"&&practice_type!="5") {
        que_div.innerHTML += "小题描述：" + question.description;
    }
    que_div.innerHTML += "<input type='hidden' name='question_type' id='question_type_"+ question.id +"' value='"+ question.correct_type +"'/>";
    parent_div.appendChild(que_div);
    //根据problem是否确定来判断question是否确定
    var question_is_sure = create_element("input", "question_sure", "question_sure_" + question.id, null, "hidden", "value");
    parent_div.appendChild(question_is_sure);
    add_que_save_button(parent_div, question.id, problem_id,practice_type);
    create_single_question(problem_title,problem_id, que_div, question,practice_type);
}

var sortRandom = function (){
    return Math.random()>0.5;
}

function create_single_question(problem_title,problem_id, que_div, question,practice_type) {
    var que_div_conlist = null;
    if(question.correct_type=="3"||question.correct_type=="5"||practice_type=="4"||practice_type=="5"){
        que_div_conlist = create_element("div", null, null, null, null, "innerHTML");
    }else{
        que_div_conlist=create_element("div", null, null, "tb_con_list", null, "innerHTML");
    }
    que_div.appendChild(que_div_conlist);
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_div_ul=create_element("ul", null, null, "chooseQuestion", null, "innerHTML");
        que_div_conlist.appendChild(que_div_ul);
        var que_attrs = question.questionattrs.split(";-;");
        if(practice_type=="4"||practice_type=="5"){
            var place_num = 1;
            while(problem_title.indexOf("problem_"+problem_id+"_dropplace_"+place_num)>=0){
                var store_id="problem_"+problem_id+"_dropplace_"+place_num;
                $(store_id).style.cursor='Move';
                Droppables.add(store_id, {
                    onDrop:function(element,store_id){
                        $(store_id).innerHTML=element.innerHTML;
                        $(store_id).style.color="blue";
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
                })
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
                                    attr.style.background="#a1e5ff";
                                    correct_sum++;
                                }else{
                                    attr.style.background="#FFCCCC";
                                }
                            }
                        } else {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        }
                        attr.innerHTML += "<label>"+ que_attrs[i] +"</label>";
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
                                    attr.style.background="#a1e5ff";
                                }else{
                                    attr.style.background="#FFCCCC";
                                }
                            }
                        } else {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                            if(check_answer==1){
                                if(true_false){
                                    attr.style.background="#FFCCCC";
                                }
                            }
                        }
                        attr.innerHTML += "<label>"+ que_attrs[i] +"</label>";
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
                        attr1.style.background="#a1e5ff";
                        correct_sum++;
                    }else{
                        attr1.style.background="#FFCCCC";
                    }
                }
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;";               
            } else {
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;";
            }
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == "0") {
                if(check_answer==1){
                    if(answer!=null&&answer.length>0&&answer[question_num-1]=="0"){
                        attr1.style.background="#a1e5ff";
                        correct_sum++;
                    }else{
                        attr1.style.background="#FFCCCC";
                    }
                }
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />错/否&nbsp;&nbsp;";
            } else {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>错/否&nbsp;&nbsp;";
            }
        } else {
            var attr1 = create_element("div", null, null, null, null, "innerHTML");
            que_div_conlist.appendChild(attr1);
            if (answer_hash != null && answer_hash[question.id] != null&&answer_hash[question.id][0].replace(/\n/g, "")!="") {
                if(practice_type=="6"){
                    var tishi =$("practice5_list_"+problem_id).value;
                    attr1.innerHTML += "<textarea style='width: 440px; height: 100px; margin: 3px 3px;' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'  onblur='if(this.value.length==0){this.value=\"提示： "+tishi+"\";}' >"+ answer_hash[question.id][0] +"</textarea>";
                }else{
                    attr1.innerHTML += "<textarea style='width: 440px; height: 100px; margin: 3px 3px;' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")' >"+ answer_hash[question.id][0] +"</textarea>";
                }
                if(check_answer==1){
                    if(answer!=null&&answer.length>0&&answer_hash[question.id][0]==answer[question_num-1]){
                        attr1.style.background="#a1e5ff";
                        correct_sum++;
                    }else{
                        attr1.style.background="#FFCCCC";
                    }
                }
            } else {
                if(practice_type=="6"){
                    var tishi =$("practice5_list_"+problem_id).value;
                    attr1.innerHTML += "<textarea style='width: 440px; height: 100px; margin: 3px 3px;' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onclick='show_que_save_button(\""+question.id+"\");this.focus();this.select();' onblur='if(this.value.length==0){this.value=\"提示： "+tishi+"\";}' >提示： "+tishi+"</textarea>";
                }else{
                    attr1.innerHTML += "<textarea style='width: 440px; height: 100px; margin: 3px 3px;' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onclick='show_que_save_button(\""+question.id+"\");this.focus();this.select();'></textarea>";
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
                        $("problem_"+problem_id+"_dropplace_"+(i+1)).style.color="green";
                    }else{
                        $("problem_"+problem_id+"_dropplace_"+(i+1)).innerHTML=question_array[i];
                        $("problem_"+problem_id+"_dropplace_"+(i+1)).style.color="red";
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

//显示考试倒计时
function show_exam_time() {
    // nextelapse是定时时间, 初始时为100毫秒
    // 注意setInterval函数: 时间逝去nextelapse(毫秒)后, onTimer才开始执行
    if (start != "00:00:00:00") {
        timer = window.setInterval("onTimer()", nextelapse);
    }
}

// 倒计时函数
function onTimer() {
    if (start == finish) {
        window.clearInterval(timer);
        $("paper_form").submit();
        setTimeout(function(){
            alert("答卷时间已到，请您停止答题，系统已经自动帮您提交试卷!")
        }, 100);
        return;
    }

    var hms = new String(start).split(":");
    var ms = new Number(hms[3]);
    var s = new Number(hms[2]);
    var m = new Number(hms[1]);
    var h = new Number(hms[0]);

    ms -= 10;
    if (ms < 0) {
        ms = 90;
        s -= 1;
        if (s < 0) {
            s = 59;
            m -= 1;
        }
        if (m < 0) {
            m = 59;
            h -= 1;
        }
    }

    var mss = ms < 10 ? ("0" + ms) : ms;
    var ss = s < 10 ? ("0" + s) : s;
    var sm = m < 10 ? ("0" + m) : m;
    var sh = h < 10 ? ("0" + h) : h;

    start = sh + ":" + sm + ":" + ss + ":" + mss;
    $("exam_time").innerHTML = sh + ":" + sm + ":" + ss;

    // 清除上一次的定时器
    window.clearInterval(timer);
    // 启动新的定时器
    timer = window.setInterval("onTimer()", nextelapse);
}

//用来5分钟存储的定时器
function local_save_start() {
    local_timer = window.setInterval("local_save()", 100);
}

//5分钟存储函数
function local_save() {
    if (local_start_time == local_finish_time) {
        window.clearInterval(local_timer);
        local_storage_answer();
        return;
    }
    var hms = new String(local_start_time).split(":");
    var ms = new Number(hms[2]);
    var s = new Number(hms[1]);
    var m = new Number(hms[0]);
    ms -= 10;
    if (ms < 0) {
        ms = 90;
        s -= 1;
        if (s < 0) {
            s = 59;
            m -= 1;
        }
        if (m < 0) {
            m = 59;
        }
    }
    var mss = ms < 10 ? ("0" + ms) : ms;
    var ss = s < 10 ? ("0" + s) : s;
    var sm = m < 10 ? ("0" + m) : m;
    local_start_time = sm + ":" + ss + ":" + mss;
    //$("local_time").innerHTML = local_start_time;
    // 清除上一次的定时器
    window.clearInterval(local_timer);
    // 启动新的定时器
    local_timer = window.setInterval("local_save()", 100);
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
    alreay_answer_que_num();
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

//用来返回考生已经答完多少道题点
function alreay_answer_que_num() {
    var total_num = 0;
    var problem_ids = $("problem_ids").value;
    if (problem_ids != null && problem_ids != "") {
        var ids_arr = problem_ids.split(",");
        for (var i=0; i<ids_arr.length; i++) {
            var question_ids = $("question_ids_" + ids_arr[i]);
            if (question_ids != null && question_ids.value != null) {
                var q_ids = question_ids.value.split(",");
                for (var j=0; j<q_ids.length-1; j++) {
                    var question_answer = $("answer_" + q_ids[j]);
                    if (question_answer != null && question_answer.value != null && question_answer.value != "") {
                        total_num ++;
                    }
                }
            }
        }
        $("complete_num").innerHTML = total_num;
    }
}

//提交试卷之前判断试卷是否已经全部答对
function generate_result_paper(paper_id,examination_id,practice_type) {
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
        create_paper(practice_type);
    //$("jiexi_tab_p").innerHTML="Sorry, 请检查错题。";
    //$("jiexi_tab").style.display="block";
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

//每隔5分钟自动存储答卷内容
function add_to_db(arr) {
    var examination_id = $("examination_id").value;
    new Ajax.Updater("remote_div", "/user/examinations/"+ examination_id +"/five_min_save",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            reload_local_save()
        },
        parameters:"arr="+ arr +"&authenticity_token=" + encodeURIComponent('BgLpQ3SADBr4tuiYZOJeoOvY4VOHogJvqQEpMwYVBM4=')
    });
    return false;
}

//重新执行5分钟倒计时
function reload_local_save() {
    if (start != finish) {
        local_start_time = "05:00:00";
        local_save_start();
    }
}

//load用户已经答完的答案
function load_answer(paper_id, examination_id) {
    if(window.openDatabase){
        load_local_save(paper_id, examination_id);
        setTimeout(function(){
            read_answer_xml();
        }, 1000);
    } else {
        read_answer_xml();
    }
}

function read_answer_xml() {
    if (answer_hash == null) {
        answer_xml();
    }
}


//load本地存储的答案
function load_local_save(paper_id, examination_id) {
    if (paper_id != "" && examination_id != "" && getCookie('user_id') != "") {
        list_answer(getCookie('user_id'), paper_id, examination_id);
    }
}

//loadxml文件
function loadxml(xmlFile) {
    var xmlDoc;
    if(window.ActiveXObject) {
        xmlDoc = new ActiveXObject('MSXML2.DOMDocument');
        xmlDoc.async = false;
        xmlDoc.load(xmlFile);
    }else if (document.implementation&&document.implementation.createDocument) {
        var xmlhttp = new window.XMLHttpRequest();
        xmlhttp.open("GET", xmlFile, false);
        xmlhttp.send(null);
        xmlDoc = xmlhttp.responseXML;
    }else{
        return null;
    }
    return xmlDoc;
}

//load答案的xml文件
function answer_xml() {
    var answer_url = $("answer_url").value;
    var xmlDom = loadxml(answer_url);
    if (xmlDom != null) {
        var questions = xmlDom.getElementsByTagName("question");
        if (questions.length > 0) {
            answer_hash = new Hash();
            for(var i=0;i<questions.length;i++){
                answer_hash[questions[i].getAttribute("id")] = [questions[i].firstChild.firstChild.nodeValue, questions[i].getAttribute("is_sure")];
            }
        }
    }
}


