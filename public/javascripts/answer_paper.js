//加载试卷
function load_paper() {
    setTimeout(function(){
        get_exam_time();
    }, 100);
}

//获取考试的时间
function get_exam_time(){
    var examination_id = $("examination_id").value;
    var user_id = $("user_id").value;
    new Ajax.Updater("true_exam_time", "/user/examinations/"+ examination_id +"/get_exam_time",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            load_exam_tiem(request.responseText);
        },
        parameters:"user_id="+ user_id +"&authenticity_token=" + encodeURIComponent('BgLpQ3SADBr4tuiYZOJeoOvY4VOHogJvqQEpMwYVBM4=')
    });
    return false;
}

//加载是否是定时考试
function load_exam_tiem(time) {
    if (time == "不限时") {
        start = 0;
        $("exam_time").innerHTML = "不限时";
    } else {
        time = Math.round(time*10)/10;
        var h = Math.floor(time/3600) < 10 ? ("0" + Math.floor(time/3600)) : Math.floor(time/3600);
        var m = Math.floor((time%3600)/60) < 10 ? ("0" + Math.floor((time%3600)/60)) : Math.floor((time%3600)/60);
        $("exam_time").innerHTML = "剩余时间  " + h + ":" + m;
        start = time;
        is_fix_time = true;
        block_start_hash = $H({});
        block_end_hash = $H({});
    }
    setTimeout(function(){
        create_paper();
    }, 500);
}

//创建试卷
function create_paper() {
    //显示基本信息部分
    $("problem_ids").value = "";
    $("paper_title").innerHTML = papers.paper.base_info.title;
    $("paper_id").value = papers.paper.id;
    $("leaving_num").innerHTML = papers.paper.total_num;
    
    if (papers.paper.blocks != undefined && papers.paper.blocks.block != undefined) {
        var blocks = papers.paper.blocks.block;
        get_block_id(blocks);
        var bocks_div = $("blocks");
        if (tof(blocks) == "array") {
            for (var i=0; i<blocks.size();i++) {
                create_block(bocks_div, blocks[i]);

            }
        } else {
            create_block(bocks_div, blocks);
        }
        next_last_index();
    }
    setTimeout(function(){
        show_exam_time();
    }, 500);
    local_save_start();
//load_scroll();
}

function get_block_id(blocks) {
    if (tof(blocks) == "array") {
        for (var i=0; i<blocks.size();i++) {
            if ($("block_ids") != null && $("block_ids").value != "") {
                $("block_ids").value = $("block_ids").value + "," + blocks[i].id;
            } else {
                $("block_ids").value = blocks[i].id;
            }
        }
    } else {
        $("block_ids").value = blocks.id;
    }
}

//添加试卷块
var question_num = 0;   //根据提点显示导航
var block_block_flag = 0;   //记录打开的模块
function create_block(bocks_div, block) {
    if (is_fix_time) {
        return_block_exam_time(block.id, block.start_time, block.time);
    }
    var block_title = "<span id='b_title_"+ block.id +"'>" + block.base_info.title + "</span>";
  
    var block_div = create_element("div", null, "block_" + block.id, "tp_left", null, "innerHTML");    
    block_div.style.display = "none";
    bocks_div.appendChild(block_div);
    var b_div = create_element("div", null, "inner_block_" + block.id, "part_box", null, "innerHTML");
    block_div.appendChild(b_div);

    var part_message = create_element("div", null, null, "part_passage", null, "innerHTML");
    var block_str = block_title;
    if (block.time != null && block.time != "" && block.time != "0") {
        block_str += " ("+ block.time +" minutes)";
    }
    part_message.innerHTML = "<div class='part_title' id='block_show'> " + block_str + " </div>";
    if (block.base_info.description != null && block.base_info.description != "") {
        part_message.innerHTML += "<p>" + is_has_audio(block.id, block.base_info.description) + "</p>";
    }
    
    b_div.appendChild(part_message);
    if ($("jquery_jplayer_" + block.id) != null) {
        generate_jplayer(block.base_info.description, block.id);
    }
    
    //试卷导航展开部分
    var navigation_div = $("paper_navigation");
    var block_nav_div = create_element("div", null, "block_nav_"+block.id, "first_title", null, "innerHTML");
    if (is_fix_time && block_start_hash.get(block.id) != null && block_start_hash.get(block.id) != "") {
        block_nav_div.innerHTML = "<p onclick='javascript:hand_open_nav(\""+block.id+"\");'>"+ block_title + "</p>";
    } else {
        block_nav_div.innerHTML = "<p onclick='javascript:open_nav(\""+block.id+"\");'>"+ block_title + "</p>";
    }
    navigation_div.appendChild(block_nav_div);
    var ul = create_element("ul", null, "nav_block_" + block.id, "second_menu", null, "innerHTML");
    ul.style.display = "none";
    block_nav_div.appendChild(ul);
    //判断problem的存在
    if (block.problems != undefined && block.problems.problem != undefined) {
        var problems = block.problems.problem;
        if (tof(problems) == "array") {
            for (var j=0; j<problems.size(); j++) {
                create_problem(b_div, problems[j], ul);
            }
        } else {
            create_problem(b_div, problems, ul);
        }
        block_nav_div.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    }
    if (block_block_flag == 0 && (is_fix_time == false || (is_fix_time && (block_start_hash.get(block.id) == ""
        || (return_giving_time(block_start_hash.get(block.id)) >= start &&
            (block_end_hash.get(block.id) == "" ||
                return_giving_time(block_end_hash.get(block.id)) < start)))))) {
        open_block_nav(block.id);
        block_block_flag = 1;
    }
}

//上一部分、下一部分
function next_last_index() {
    if ($("block_ids") != null && $("block_ids").value != "") {
        var block_ids = $("block_ids").value.split(",");
        if (block_ids != null) {
            if (block_ids.length > 1) {
                for (var i=0; i<block_ids.length; i++) {
                    var next_div = null;
                    if ($("testPage_btn_" + block_ids[i]) == null) {
                        next_div = create_element("div", null, "testPage_btn_" + block_ids[i], "testPage_btn", null, "innerHTML");
                    } else {
                        next_div = $("testPage_btn_" + block_ids[i]);
                    }
                    var method_str = "";
                    var next_method = "";
                    var next_block_id = "";
                    var last_block_id = "";
                    if (block_ids.indexOf(block_ids[i]) == 0) {
                        next_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) + 1];
                        method_str = (is_fix_time && block_start_hash.get(next_block_id) != null && block_start_hash.get(next_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_down_btn' onclick='javascript:" + method_str
                        + "(\""+ next_block_id +"\");'>下一部分</a>";
                    } else if (block_ids.indexOf(block_ids[i]) == block_ids.length - 1) {
                        last_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) - 1];
                        method_str = (is_fix_time && block_start_hash.get(last_block_id) != null && block_start_hash.get(last_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_up_btn' onclick='javascript:" + method_str
                        + "(\""+ last_block_id +"\");'>上一部分</a>";
                    } else {
                        next_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) + 1];
                        method_str = (is_fix_time && block_start_hash.get(next_block_id) != null && block_start_hash.get(next_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        last_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) - 1];
                        next_method = (is_fix_time && block_start_hash.get(last_block_id) != null && block_start_hash.get(last_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_down_btn' onclick='javascript:"
                        + method_str + "(\""+ next_block_id +"\");'>下一部分</a><a href='javascript:void(0);' class='tp_up_btn' onclick='javascript:" + next_method
                        + "(\""+ last_block_id +"\");'>上一部分</a>";
                    }
                    $("block_" + block_ids[i]).appendChild(next_div);
                }
            }
        }
    }
}

//返回模块的考试结束时间
function return_block_exam_time(block_id, start_time, time) {
    var end_time = "";
    var b_start_time = "";
    if (start_time != null && start_time != "") {
        var t = start_time.split(":");
        var h = new Number(t[0]);
        var m = new Number(t[1]);
        var sh = h < 10 ? ("0" + h) : h;
        var sm = m < 10 ? ("0" + m) : m;
        b_start_time = sh + ":" + sm + ":00";
        if (time != "" && time != "0") {
            var total_m = h * 60 + m - new Number(time);
            h = (total_m >= 60) ? Math.floor(total_m/60) : 0;
            m = (total_m >= 60) ? new Number(total_m%60) : total_m;
            var eh = h < 10 ? ("0" + h) : h;
            var em = m < 10 ? ("0" + m) : m;
            end_time = eh + ":" + em + ":00";
        }
    }
    block_start_hash.set(block_id, b_start_time);
    block_end_hash.set(block_id, end_time);
}

//打开模块
function open_nav(block_id) {
    var block_ids = $("block_ids");
    if (block_ids != null && block_ids.value != "") {
        var b_ids = block_ids.value.split(",");
        if (b_ids != null) {
            for (var i=0; i<b_ids.length; i++) {
                close_block_nav(b_ids[i]);
            }
        }
    }
    open_block_nav(block_id);
}

//打开模块
function open_block_nav(block_id) {
    $("block_nav_" + block_id).className = "first_title highLight";
    $("nav_block_" + block_id).style.display = "block";
    $("block_" + block_id).style.display = "block";
    window.scrollTo(0, 0);
    if (is_fix_time) {
        start_block_audio(block_id);
    }
}

//关闭模块
function close_block_nav(block_id) {
    $("block_nav_" + block_id).className = "first_title";
    $("nav_block_" + block_id).style.display = "none";
    $("block_" + block_id).style.display = "none";
}

//根据定时返回时间
function return_giving_time(time) {
    var times =  time.split(":");
    var ss = new Number(times[2]) + (new Number(times[1])) * 60 + (new Number(times[0])) * 3600;
    return ss;
}

//手动打开模块
function hand_open_nav(block_id) {
    if (is_fix_time) {
        var fs = start;
        var flash_div = null;
        var bs = null;
        var end_time_flag = false;
        if (block_end_hash.get(block_id) != null && block_end_hash.get(block_id) != "") {
            bs = return_giving_time(block_end_hash.get(block_id));
        }
        if (block_start_hash.get(block_id) != null && block_start_hash.get(block_id) != "") {
            var ss = return_giving_time(block_start_hash.get(block_id));
            if (ss < fs) {
                flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
                flash_div.innerHTML = "<p>当前部分还未可以开始答题。</p>";
                document.body.appendChild(flash_div);
                show_flash_div();
            }
            else {
                end_time_flag = true;
            }
        } else {
            end_time_flag = true;
        }
        if (end_time_flag == true) {
            if (bs == null || bs < fs) {
                open_nav(block_id);
            } else {
                flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
                flash_div.innerHTML = "<p>当前部分答题时间固定，答题时间已过。</p>";
                document.body.appendChild(flash_div);
                show_flash_div();
            }
        }
    } else {
        open_nav(block_id);
    }
}

//生成试卷提点导航
function create_question_navigation(block_nav_div, question, problem_id, question_num) {
    var question_nav_li = create_element("li", null, "question_nav_"+question.id, null, null, "innerHTML");
    question_nav_li.innerHTML = "<a href='javascript:void(0);' id='a_que_nav_"+ question.id 
    +"' onclick='javascript:get_question_height(\""+question.id+"\", \""+problem_id+"\");'>"+ question_num +"</a>";
    block_nav_div.appendChild(question_nav_li);
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
                    if ($("question_" + p_ids[i]) != null) {
                        p_height += $("question_" + p_ids[i]).offsetHeight;
                    }
                }
            }
        }
    }
    var question_ids = $("question_ids_" + problem_id).value;
    if ($("problem_title_" + problem_id) != null && $("problem_title_" + problem_id) != undefined) {
        p_height += $("problem_title_" + problem_id).offsetHeight;
    }
    if (question_ids != null) {
        var q_ids = question_ids.split(",");
        if (q_ids != null) {
            for (var j=0; j<q_ids.length; j++) {
                if (q_ids[j] == question_id) {
                    break;
                }
                else {
                    if ($("que_out_" + q_ids[j]) != null) {
                        p_height += $("que_out_" + q_ids[j]).offsetHeight;
                    }
                }
            }
        }
    }
    window.scrollTo(100, p_height);
}

//添加problem
function create_problem(block_div, problem, block_nav_div) {
    if (problem.id == null || problem.id == undefined) {
        var question_text_explain = create_element("div", null, null, "question_text_explain", null, "innerHTML");
        question_text_explain.innerHTML = "<p><em>" + problem.part_description + "</em></p>";
        block_div.appendChild(question_text_explain);
    }
    else {
        var b_description_div = create_element("div", null, "b_description_" + problem.id, "part_div", null, "innerHTML");
        block_div.appendChild(b_description_div);
        var out_que_div = create_element("div", null, "question_" + problem.id, "part_question", null, "innerHTML");
        if (problem.title != null && problem.title != "") {
            var titles = problem.title.split("<time>");
            if (titles[0] != "" || titles[2] != "") {
                var complete_title = "";
                if (titles[0] != null && titles[0] != "") {
                    complete_title += replace_title_span(titles[0], problem.id);
                }
                if (titles[2] != null && titles[2] != "") {
                    complete_title += replace_title_span(titles[2], problem.id);
                }
                out_que_div.innerHTML = "<div class='part_q_text' id='problem_title_"+ problem.id
                +"'><div class='question_text_div'>"
                + complete_title + "</div></div>";
            } 
        }
        b_description_div.appendChild(out_que_div);

        var question_id_input = create_element("input", "question_ids", "question_ids_" + problem.id, null, "hidden", "value");
        //添加question所需div
        var drag_li_arr = [];  //拖动框的div
        if (problem.questions != undefined && problem.questions.question != undefined) {
            var questions = problem.questions.question;
            if (tof(questions) == "array") {
                for (var j=0; j<questions.size(); j++) {
                    create_question_navigation(block_nav_div, questions[j], problem.id, question_num);
                    create_question(problem.id, question_id_input, out_que_div, questions[j], question_num, drag_li_arr);
                    question_num ++ ;
                }
            } else {
                create_question_navigation(block_nav_div, questions, problem.id, question_num);
                create_question(problem.id, question_id_input, out_que_div, questions, question_num, drag_li_arr);
                question_num ++ ;
            }
        }
        if (drag_li_arr.length > 0) {
            create_words_div(problem.id, drag_li_arr);
        }
        out_que_div.appendChild(question_id_input);
        var is_answer_input = create_element("input", "is_answer", "is_answer_" + problem.id, null, "hidden", "value");
        out_que_div.appendChild(is_answer_input);
        var is_sure_input = create_element("input", "is_sure", "is_sure_" + problem.id, null, "hidden", "value");
        out_que_div.appendChild(is_sure_input);

        $("problem_ids").value += "" + problem.id + ",";
        if (answer_hash != null) {
            load_un_sure_question(problem.id);
            is_problem_answer(problem.id);
            alreay_answer_que_num();
        }
    }
}

//增加提点保存和不确定按钮
function add_que_save_button(parent_div, question_id, problem_id) {
    var buttons_div = create_element("div", null, "save_button_" + question_id, "p_question_btn", null, "innerHTML");
    buttons_div.innerHTML = "<input type='button' name='question_submit' class='save' onclick='javascript:generate_question_answer(\""+ question_id +"\", \""+problem_id+"\", \"1\");' value=''/>";
    buttons_div.innerHTML += "<input type='button' name='question_button' class='Uncertain' onclick='javascript:generate_que_unsure_answer(\""+ question_id +"\", \""+problem_id+"\", \"0\");' value=''/>";
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
function create_question(problem_id, question_id_input, parent_div, question, innerHTML, drag_li_arr) {
    $("all_question_ids").value += "" + question.id + ",";
    question_id_input.value += "" + question.id + ",";   
    parent_div.innerHTML += "<input type='hidden' name='question_type' id='question_type_"+ question.id +"' value='"+ question.correct_type +"'/>";
    //根据problem是否确定来判断question是否确定
    var question_is_sure = create_element("input", "question_sure", "question_sure_" + question.id, null, "hidden", "value");
    parent_div.appendChild(question_is_sure);
    //    if (question.correct_type == "6") {
    //        create_draggable_div(question, parent_div);
    //    }
    var que_out_div = create_element("div", null, "que_out_" + question.id, "p_question_list", null, "innerHTML");
    que_out_div.innerHTML = "<div class='p_q_l_left'>" + innerHTML + "</div>";
    parent_div.appendChild(que_out_div);
    var single_question_div = create_element("div", null, "single_question_" + question.id, "p_q_l_right", null, "innerHTML");
    if (question.description != undefined && question.description != null && question.description != "") {
        var final_description = replace_title_span(question.description, problem_id);
        if (question.correct_type == "6") {
            single_question_div.innerHTML += "<div class='q_drag_con'><p>" +
            final_description + "</p></div>";
        } else {
            single_question_div.innerHTML += "<div class='question_title'>" +
            final_description + "</div>";
        }
    }
    que_out_div.appendChild(single_question_div);
    que_out_div.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    //    if (question.correct_type == "6") {
    //        store_title_span(problem_id, question.id);
    //    }
    create_single_question(single_question_div, question, drag_li_arr);
    create_answer_area(single_question_div, question, problem_id);
}

//创建拖拽区域
function create_draggable_div(question, que_div) {
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_attrs = question.questionattrs.split(";-;");
        que_attrs = que_attrs.sort(function(){
            return Math.random()>0.5?-1:1;
        });
        var drop_div = create_element("div", null, null, "task3_li", null, "innerHTML");
        que_div.appendChild(drop_div);
        var drop_ul = create_element("ul", null, null, null, null, "innerHTML");
        drop_div.appendChild(drop_ul);
        for (var m=0; m<que_attrs.length; m++) {
            if (que_attrs[m] != null && que_attrs[m] != "") {
                var drag_attr = create_element("li", null, null, null, null, "innerHTML");
                drag_attr.innerHTML = que_attrs[m];
                drop_ul.appendChild(drag_attr);
                new Draggable(drag_attr,{
                    revert:true
                });
                drag_attr.style.cursor='Move';
            }
        }
    }
}

//创建完型填空选词列表
function create_words_div(problem_id, drag_li_arr) {
    if ($("problem_title_" + problem_id) != null) {
        var que_attrs = drag_li_arr.sort(function(){
            return Math.random()>0.5?-1:1;
        });
        var drop_div = create_element("div", null, null, "task3_li", null, "innerHTML");
        $("problem_title_" + problem_id).appendChild(drop_div);
        var tip_div = create_element("div", null, null, null, null, "innerHTML");
        tip_div.innerHTML = "<font color='red'>*</font>点击单词，可以标记单词被选中。";
        drop_div.appendChild(tip_div);
        var drop_ul = create_element("ul", null, null, null, null, "innerHTML");
        drop_div.appendChild(drop_ul);
        for (var m=0; m<que_attrs.length; m++) {
            if (que_attrs[m] != null && que_attrs[m] != "") {
                var drag_attr = create_element("li", null, null, "", null, "innerHTML");
                drag_attr.innerHTML = que_attrs[m];
                drop_ul.appendChild(drag_attr);
                drag_attr.onclick = function(){
                    change_word_color(this)
                };
            }
        }
    }
}

//更改单词的颜色
function change_word_color(drag_attr) {
    if (drag_attr.className == "dropOver") {
        drag_attr.className = "";
    } else {
        drag_attr.className = "dropOver";
    }
}

//创建不同题型
function create_single_question(que_div, question, drag_li_arr) {
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_attrs = question.questionattrs.split(";-;");
        if (question.correct_type == "6") {
            var drag_div = create_element("div", null, null, "answer_text", null, "innerHTML");
            if (answer_hash != null && answer_hash[question.id] != null) {
                que_div.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                + question.id +"' style='height: 24px;' onclick='javascript:show_que_save_button(\""+question.id+"\")'>"
                + answer_hash[question.id][0] +"</textarea>";
            } else {
                que_div.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                + question.id +"' style='height: 24px;' onclick='javascript:show_que_save_button(\""+question.id+"\")'></textarea>";
            }
            que_div.appendChild(drag_div);
        } else {
            var ul = create_element("ul", null, null, "chooseQuestion", null, "innerHTML");
            que_div.appendChild(ul);
        }
        for (var i=0; i<que_attrs.length; i++) {
            if (que_attrs[i] != null && que_attrs[i] != "") {
                if (question.correct_type == "6") {
                    drag_li_arr.push(que_attrs[i]);
                    
                } else {
                    var attr = create_element("li", null, null, null, null, "innerHTML");
                    ul.appendChild(attr);
                    if (question.correct_type == "0") {
                        if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == que_attrs[i]) {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />";
                        } else {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        }
                    } else if (question.correct_type == "1") {
                        if (answer_hash != null &&  answer_hash[question.id] != null && answer_hash[question.id][0].split(";|;").include(que_attrs[i])) {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        } else {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        }
                    }
                    attr.innerHTML += "&nbsp;&nbsp;"+ que_attrs[i];
                }
            }
        }
    } else {
        var attr1 = null ;
        if (question.correct_type == "2") {
            attr1 = create_element("div", null, null, "answer_textarea", null, "innerHTML");
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == "1") {
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;";
            } else {
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;";
            }
            
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == "0") {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />错/否&nbsp;&nbsp;";
            } else {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>错/否&nbsp;&nbsp;";
            }
        } else {
            if (question.correct_type == "3") {
                attr1 = create_element("div", null, null, "answer_text", null, "innerHTML");
                if (answer_hash != null && answer_hash[question.id] != null) {
                    attr1.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                    + question.id +"' onfocus='javascript:start_change_length(\""+ question.id
                    +"\")' onblur='javascript:window.clearInterval(change_length);' style='height: 24px;'>"
                    + answer_hash[question.id][0] +"</textarea>";
                } else {
                    attr1.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                    + question.id +"' onfocus='javascript:start_change_length(\""+ question.id
                    +"\")' onblur='javascript:window.clearInterval(change_length);' style='height: 24px;'></textarea>";
                }
            } else {
                attr1 = create_element("div", null, null, "answer_textarea", null, "innerHTML");
                if (answer_hash != null && answer_hash[question.id] != null) {
                    attr1.innerHTML += "<textarea cols='35' rows='3' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'>"+ answer_hash[question.id][0] +"</textarea>";
                } else {
                    attr1.innerHTML += "<textarea cols='35' rows='3' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'></textarea>";
                }
            }
            
        }
        que_div.appendChild(attr1);
    }
}

//创建按钮已经答案区域
function create_answer_area(que_div, question, problem_id) {
    add_que_save_button(que_div, question.id, problem_id);
    var answer_input = create_element("input", "answer_" + question.id, "answer_" + question.id, null, "hidden", "value");
    if (answer_hash != null && answer_hash[question.id] != null) {
        answer_input.value = answer_hash[question.id][0];
    }
    que_div.appendChild(answer_input);
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
var exam_time_start = null;
function show_exam_time() {
    // 注意setInterval函数: 时间逝去100(毫秒)后, onTimer才开始执行
    if (start != 0) {
        exam_time_start = new Date();
        timer = self.setInterval(function(){
            onTimer();
        }, 100);
    }
}

// 倒计时函数
function onTimer() {
    var date_start = new Date();
    if (start <= 0) {
        window.clearInterval(timer);
        $("paper_form").submit();
        setTimeout(function(){
            var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
            flash_div.innerHTML = "<p>答卷时间已到，请您停止答题，系统已经自动帮您提交试卷</p>";
            document.body.appendChild(flash_div);
            show_flash_div();
        }, 100);
        return;
    }  
    var current_time = start;

    var m = Math.floor((current_time%3600)/60);
    var h = Math.floor(current_time/3600);
    var sm = m < 10 ? ("0" + m) : m;
    var sh = h < 10 ? ("0" + h) : h;
    
    $("exam_time").innerHTML = "剩余时间  " + sh + ":" + sm;
    $("true_exam_time").innerHTML = start;

    colse_or_open_block(current_time);
    if (start%150 == 0) {
        get_sever_time();
    }
    var date_end = new Date();
    if (start != 0) {
        if ((date_end - exam_time_start) > 500 && (date_end - exam_time_start) < 5000) {
            start = Math.round((start - (date_end - exam_time_start)/1000)*10)/10;
        } else {
            start = Math.round((start - 0.1 - (date_end - date_start)/1000)*10)/10;
        }
    }
    exam_time_start = date_end;
}

//打开模块和关闭答案
function colse_or_open_block(current_time) {
    if (is_fix_time) {
        var has_close_block = false;
        var all_block_end_time = block_end_hash.values();
        for (var j=0; j<all_block_end_time.length; j++) {
            var b_id = block_end_hash.index(all_block_end_time[j]);
            var block_title = $("b_title_" + b_id).innerHTML;
            var block_time = return_giving_time(all_block_end_time[j]);
            if (block_time == current_time || (block_time > current_time && $("block_" + b_id).style.display != "none")) {
                var flash_div = create_element("div", null, "flash_notice", "white_tab_box", null, "innerHTML");
                flash_div.innerHTML = "<a href='javascript:void(0);' class='white_box_x' onclick='javascript:flash_remove(this);'><img src='/images/paper/x.gif'></a>"
                + "<div class='clear'></div><div class='white_box_text'>"
                + block_title + " 部分答题时间已到，您的答案将自动被提交，请您继续做其它部分的题。</div>";
                document.body.appendChild(flash_div);
                show_flash_not_close();
                window.clearInterval(local_timer);
                local_storage_answer("open");
                has_close_block = true;
                break;
            } else if (Math.floor(current_time - block_time) == 60) {
                var flash_div1 = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
                flash_div1.innerHTML = "<p>当前 "+block_title+" 部分剩余答题时间为1分钟，请您尽快答题，并提交答案。</p>";
                document.body.appendChild(flash_div1);
                show_flash_div();
            }
        }
        if (has_close_block) {
            var all_block_start_time = block_start_hash.values();
            var has_next_block = false;
            for (var i=0; i<all_block_start_time.length; i++) {
                if (all_block_start_time[i] == current_time) {
                    open_nav(block_start_hash.index(all_block_start_time[i]));
                    has_next_block = true;
                    break;
                }
            }
            if (has_next_block == false) {
                for (var k=0; k<all_block_start_time.length; k++) {
                    var block_id = block_start_hash.index(all_block_start_time[k]);
                    if (all_block_start_time[k] == ""
                        || (return_giving_time(all_block_start_time[k]) >= current_time &&
                            (block_end_hash.get(block_id) == "" ||
                                return_giving_time(block_end_hash.get(block_id)) < current_time))) {
                        open_nav(block_id);
                        break;
                    }
                }
            }
        }
    }
}

//用来5分钟存储的定时器
var local_save_time = null;
function local_save_start() {
    local_save_time = new Date();
    local_timer = self.setInterval(function(){
        local_save();
    }, 100);
//    local_timer = self.setTimeout(function(){
//        local_save();
//    }, 100);
}

//5分钟存储函数
function local_save() {
    var start_date = new Date();
    if (local_start_time <= 0) {
        window.clearInterval(local_timer);
        local_storage_answer("open");
        return;
    }
    
    var end_date = new Date();
    if ((end_date - local_save_time) > 500 && (end_date - local_save_time) < 5000) {
        local_start_time = Math.round((local_start_time - (end_date - local_save_time)/1000)*10)/10;
    } else {
        local_start_time = Math.round((local_start_time - 0.1 - (end_date - start_date)/1000)*10)/10;
    }
    local_save_time = end_date;
}

//用来1分钟取一下服务器时间
function get_sever_time() {
    var examination_id = $("examination_id").value;
    var user_id = $("user_id").value;
    new Ajax.Updater("true_exam_time", "/user/examinations/"+ examination_id +"/get_exam_time",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            if ($("true_exam_time").innerHTML == "不限时") {
                start = 0;
                $("exam_time").innerHTML = "不限时";
            } else {
                start = Math.round(new Number(request.responseText)*10)/10;
                var h = Math.floor(start/3600) < 10 ? ("0" + Math.floor(start/3600)) : Math.floor(start/3600);
                var m = Math.floor((start%3600)/60) < 10 ? ("0" + Math.floor((start%3600)/60)) : Math.floor((start%3600)/60);
                $("exam_time").innerHTML = "剩余时间  " + h + ":" + m;
            }
        },
        parameters:"user_id="+ user_id +"&authenticity_token=" + encodeURIComponent('BgLpQ3SADBr4tuiYZOJeoOvY4VOHogJvqQEpMwYVBM4=')
    });
    return false;
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
function is_problem_answer(problem_id) {
    var answer_flag = "";
    var question_ids = $("question_ids_" + problem_id).value;
    if (question_ids != "") {
        var ids = question_ids.split(",");
        var is_answer_num = 0;
        for (var i=0; i<ids.length-1; i++) {
            var question_div = $("que_out_" + ids[i]);
            if (question_div != null) {
                var is_answer = question_value(ids[i], problem_id);
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
    }
    if (answer_flag == "all") {
        $("is_answer_" + problem_id).value = "1";
    } else {
        $("is_answer_" + problem_id).value = "";
    }
    return answer_flag;
}

//用来返回提点是否已经回答
function generate_question_answer(question_id, problem_id, is_sure) {
    $("question_sure_" + question_id).value = "" + is_sure;
    question_color(question_id);
    is_problem_answer(problem_id);
    save_question(question_id, is_sure);
    alreay_answer_que_num();
    $("save_button_" + question_id).style.display = "none";
}

//使用本地存储保存提点内容
function save_question(question_id, is_sure) {
    var paper_id = $("paper_id").value;
    var examination_id = $("examination_id").value;
    var answer = $("answer_" + question_id);
    if(window.openDatabase){
        if (answer != null && !checkspace(answer.value)) {
            remove_answer(question_id, getCookie('user_id'), paper_id, examination_id);
            add_answer(question_id, getCookie('user_id'), paper_id, examination_id, answer.value, is_sure);

        }
    }
}

//提点颜色
function question_color(question_id) {
    if ($("question_sure_"+question_id).value == "1") {
        $("que_out_" + question_id).className = "p_question_list question_yes";
        $("a_que_nav_" + question_id).className = "lvse";
    } else {
        $("que_out_" + question_id).className = "p_question_list question_no";
        $("a_que_nav_" + question_id).className = "fenhong";
    }
}

function generate_que_unsure_answer(question_id, problem_id, is_sure) {
    generate_question_answer(question_id, problem_id, is_sure);
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
                question_color(ids[i]);
            }
        }
    }
}

//用来返回每个提点是否已经回答
function question_value(question_id, problem_id) {
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
    } else if (correct_type == "3" || correct_type == "5" || correct_type == "6") {
        var answer = $("question_answer_" + question_id);
        if (answer != null && !checkspace(answer.value)) {
            is_answer = true;
            $("answer_" + question_id).value = answer.value;
        }
    }// else {
    //        var place_num = 1;
    //        var str = document.getElementById("question_" + problem_id).innerHTML;
    //        while(str.indexOf("problem_" + problem_id + "_dropplace_" + place_num) >= 0) {
    //            if ($("answer_" + question_id).value == "") {
    //                $("answer_" + question_id).value = $("problem_" + problem_id + "_dropplace_" + place_num).innerHTML;
    //            } else {
    //                $("answer_" + question_id).value += ";|;" + $("problem_" + problem_id + "_dropplace_" + place_num).innerHTML;
    //            }
    //            is_answer = true;
    //            place_num ++ ;
    //        }
    //    }
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
        $("leaving_num").innerHTML = papers.paper.total_num - total_num;
    }
}

//提交试卷之前判断试卷是否已经全部答完
function generate_result_paper(paper_id) {
    var flag = true;
    //var all_question_ids = $("all_question_ids").value;
    var all_problem_ids = $("problem_ids");
    if (all_problem_ids != null && all_problem_ids.value != "") {
        var problem_ids = all_problem_ids.value.split(",");
        var answer_length = 0;
        for (var i=0; i<problem_ids.length-1; i++) {
            var is_answer = $("is_answer_" + problem_ids[i]);
            if (is_answer != null && is_answer.value != null) {
                if (is_answer.value == "1") {
                    answer_length++ ;
                }
            }            
        }
        if (answer_length < (problem_ids.length-1)) {
            if(!confirm('您还有题尚未答完，确定要交卷么?')) {
                flag = false;
            }
        }
    }
    return flag;
}

function local_storage_answer(flag) {
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
            add_to_db(arr, flag);
        }
    }
}

//每隔5分钟自动存储答卷内容
function add_to_db(arr, flag) {
    var examination_id = $("examination_id").value;
    new Ajax.Request("/user/examinations/"+ examination_id +"/five_min_save",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            if (flag == "open") {
                reload_local_save();
            } else {
                window.close();
            }
        },
        parameters:"arr="+ arr +"&authenticity_token=" + encodeURIComponent('BgLpQ3SADBr4tuiYZOJeoOvY4VOHogJvqQEpMwYVBM4=')
    });
    return false;
}

//重新执行5分钟倒计时
function reload_local_save() {
        local_start_time = 300;
        local_save_start();
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
                var answer = questions[i].getElementsByTagName("answer")[0].firstChild != null ?
                questions[i].getElementsByTagName("answer")[0].firstChild.data : "";
                answer_hash[questions[i].getAttribute("id")] = [answer, questions[i].getAttribute("is_sure")];
            }
        }
    }
}

//记录当前模块是否有听力
function is_has_audio(block_id, description) {
    var titles = description.split("<mp3>");
    var final_title = "";
    if (titles.length > 1) {
        var audio_str = "";
        if (is_fix_time) {
            audio_str = "<div id='jquery_jplayer_"+ block_id +"' class='jp-jplayer' style='width:0px;height:1px;'></div>";
        } else {
            audio_str = generate_jplayer_div(block_id);
        }
        final_title = titles[0] + audio_str;
    } else {
        final_title = description;
    }
    return final_title;
}

function generate_jplayer_div(block_id) {
    var final_title = "<div id='jquery_jplayer_" + block_id + "' class='jp-jplayer'></div>"
    + "<div id='jp_container_1' class='jp-audio'><div class='jp-type-single'><div class='jp-gui jp-interface'>"
    + "<ul class='jp-controls'><li><a href='javascript:;' class='jp-play' tabindex='1'>play</a></li>"
    + "<li><a href='javascript:;' class='jp-pause' tabindex='1'>pause</a></li>"
    + "<li><a href='javascript:;' class='jp-stop' tabindex='1'>stop</a></li>"
    + "<li><a href='javascript:;' class='jp-mute' tabindex='1' title='mute'>mute</a></li>"
    + "<li><a href='javascript:;' class='jp-unmute' tabindex='1' title='unmute'>unmute</a></li>"
    + "<li><a href='javascript:;' class='jp-volume-max' tabindex='1' title='max volume'>max volume</a></li></ul>"
    + "<div class='jp-progress'><div class='jp-seek-bar'><div class='jp-play-bar'></div></div></div>"
    + "<div class='jp-volume-bar'><div class='jp-volume-bar-value'></div></div>"
    + "<div class='jp-time-holder'><div class='jp-current-time'></div><div class='jp-duration'></div></div></div></div></div>";
    return final_title;
}

function generate_jplayer(description, block_id) {
    (function(){
        var back_server_path = $("back_server_url").value;
        var titles = description.split("<mp3>");
        jQuery("#jquery_jplayer_"+block_id).jPlayer({
            ready: function() {
                jQuery(this).jPlayer("setMedia", {
                    mp3:""+back_server_path + titles[1]
                });
            },
            ended: function(){
                add_audio_cookies(block_id);
            },
            swfPath: "/javascripts/jplayer",
            supplied: "mp3",
            wmode: "window"
        });
    })(jQuery)
}

//替换问题中隐藏的span，变为可拖动
function replace_title_span(title, problem_id) {
    var final_title = "";
    if (title.indexOf("problem_x_dropplace") > 0) {
        final_title = title.replace(/problem_x/g, "problem_" + problem_id);
    } else {
        final_title = title;
    }
    return final_title;
}

//将隐藏的span变成可拖拽的
function store_title_span(problem_id, question_id) {
    var str = document.getElementById("question_" + problem_id).innerHTML;
    var place_num = 1;
    while(str.indexOf("problem_" + problem_id + "_dropplace_" + place_num) >= 0){
        var store_id = "problem_" + problem_id + "_dropplace_" + place_num;
        $(store_id).style.cursor = 'Move';
        $(store_id).className = "task_span";
        Droppables.add(store_id, {
            onDrop:function(element,store_id){
                $(store_id).innerHTML = element.innerHTML;
                $(store_id).style.color = "#96AE89";
                show_que_save_button(question_id);
            }
        })
        place_num ++;
    }
    if (answer_hash != null &&  answer_hash[question_id] != null && answer_hash[question_id][0] != null) {
        var answers = [];
        answers = answer_hash[question_id][0].split(";|;");
        for (var i=1; i<=place_num; i++) {
            if (answers[i-1] != null && answers[i-1] != "") {
                $("problem_" + problem_id + "_dropplace_" + i).innerHTML =  answers[i-1];
                $("problem_" + problem_id + "_dropplace_" + i).style.color = "#96AE89";
            }
        }
    }

}

//当打开的模块有音频时，播放有音频
function start_block_audio(block_id) {
    if ($("jquery_jplayer_" + block_id) != null) {
        var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
        if (getCookie("exam_audio_" + block_id) == null || new Number(getCookie("exam_audio_" + block_id)) == 0) {
            flash_div.innerHTML = "<p>您当前打开的模块为听力模块，听力正在播放或者即将播放，请做好答题准备。</p>";
            document.body.appendChild(flash_div);
            show_flash_div();
            setTimeout(function(){
                control_media(block_id);
            }, 5000);
        } else {
            flash_div.innerHTML = "<p>听力播放结束，请抓紧时间答题。</p>";
            document.body.appendChild(flash_div);
            show_flash_div();
        }
    }
}

//控制音频内容
var remember_time_flag = 0;
function control_media(audio_id) {
    try {
        var audio = jQuery("#jquery_jplayer_"+audio_id);
        if (getCookie("audio_time_" + audio_id) != "end") {
            if(getCookie("exam_audio_" + audio_id) == null){
                setCookie("exam_audio_" + audio_id, 0);
            }
            if(new Number(getCookie("exam_audio_" + audio_id)) < 1){
                if (getCookie("audio_time_" + audio_id) != null) {
                    audio.jPlayer("play", parseFloat(getCookie("audio_time_" + audio_id)));
                } else {
                    audio.jPlayer("play", 0);
                }
                audio.bind(jQuery.jPlayer.event.timeupdate, function(event) {
                    if (event.jPlayer.status.currentTime != null) {
                        setCookie("audio_time_" + audio_id, event.jPlayer.status.currentTime);
                    }
                    if (remember_time_flag == 0) {
                        remember_time_flag = 1;
                        if (block_end_hash.get(audio_id) != null && block_end_hash.get(audio_id) != "") {
                            var time = return_giving_time(block_start_hash.get(audio_id)) - return_giving_time(block_end_hash.get(audio_id)) ;
                            if (time < parseFloat(event.jPlayer.status.duration)) {
                                var total_time = return_giving_time(block_end_hash.get(audio_id)) + time
                                - Math.ceil(parseFloat(event.jPlayer.status.duration)) ;
                                block_end_hash.set(audio_id,
                                    (Math.floor(total_time/3600) + ":" + Math.floor(total_time%3600/60) + ":" + total_time%3600%60));
                                var block_ids = $("block_ids").value.split(",");
                                var next_block_id = "" + block_ids[block_ids.indexOf(audio_id) + 1];
                                if (block_start_hash.get(next_block_id) != null){
                                    var next_start_time = return_giving_time(block_start_hash.get(next_block_id))
                                    - (Math.ceil(parseFloat(event.jPlayer.status.duration)) - time);
                                    block_start_hash.set(next_block_id,
                                        (Math.floor(next_start_time/3600) + ":" + Math.floor(next_start_time%3600/60) + ":" + next_start_time%3600%60));
                                }

                            }
                        }
                    }
                });
                
            }
        }
    }catch (e) {
        var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
        flash_div.innerHTML = "<p>音频文件不能播放，请您检查您的音频文件是否存在。</p>";
        document.body.appendChild(flash_div);
        show_flash_div();
    }
}

//记录听力已经播放
function add_audio_cookies(audio_id) {
    if (getCookie("exam_audio_" + audio_id) != null) {
        setCookie("exam_audio_" + audio_id, new Number(getCookie("exam_audio_" + audio_id))+1);
        setCookie("audio_time_" + audio_id, "end");

        var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
        flash_div.innerHTML = "<p>听力播放结束，请抓紧时间答题。</p>";
        document.body.appendChild(flash_div);
        show_flash_div();
    }
}

//更改文本域的长度
function start_change_length(id) {
    show_que_save_button(id);
    change_length = window.setInterval("call_me(48, " + id + ")", 1);
}

//根据字符长度改变文本域的长和宽
function call_me(max_length, id) {
    if(($("question_answer_" + id).value != null ) || ($("question_answer_" + id).value != "" )) {
        if(($("question_answer_" + id).value.length >= 20) && ($("question_answer_" + id).value.length < max_length)) {
            $("question_answer_" + id).style.width = $("question_answer_" + id).value.length*10 + "px";
        } else if ($("question_answer_" + id).value.length == max_length) {
            $("question_answer_" + id).style.width = max_length*10 + "px";
        } else if ($("question_answer_" + id).value.length > max_length) {
            $("question_answer_" + id).style.width = max_length*10 + 100 + "px";
            if ($("question_answer_" + id).style.height == "120px") {
                $("question_answer_" + id).style.height = "120px";
            } else if ($("question_answer_" + id).value.length > 80 && $("question_answer_" + id).value.length < 160 && $("question_answer_" + id).style.height == "24px") {
                $("question_answer_" + id).style.height = 48 + "px";
            } else if ($("question_answer_" + id).value.length >= 160 && $("question_answer_" + id).value.length%80 == 0) {
                $("question_answer_" + id).style.height = 24*($("question_answer_" + id).value.length/80 + 1) + "px";
            }
        }
    }
}

//退出考试
function out_exam() {
    local_storage_answer("close");
}