//加载试卷
function load_paper() {
    setTimeout(function(){
        get_exam_time();
    }, 500);
}

//获取考试的时间
function get_exam_time(){
    var examination_id = $("examination_id").value;
    var user_id = $("user_id").value;
    new Ajax.Updater("exam_time", "/user/examinations/"+ examination_id +"/get_exam_time",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        onComplete:function(request){
            load_exam_tiem()
        },
        parameters:"user_id="+ user_id +"&authenticity_token=" + encodeURIComponent('BgLpQ3SADBr4tuiYZOJeoOvY4VOHogJvqQEpMwYVBM4=')
    });
    return false;
}

//加载是否是定时考试
function load_exam_tiem() {
    if ($("exam_time").innerHTML == "不限时") {
        start = "00:00:00:00";
    } else {
        start = $("exam_time").innerHTML + ":00";
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
        var bocks_div = $("blocks");
        if (tof(blocks) == "array") {
            for (var i=0; i<blocks.size();i++) {
                create_block(bocks_div, blocks[i], i);
            }
        } else {
            create_block(bocks_div, blocks, 0);
        }
    }
    setTimeout(function(){
        show_exam_time();
    }, 500);
    local_save_start();
//load_scroll();
}

//添加试卷块
var question_num = 1;   //根据提点显示导航
var block_block_flag = 0;   //记录打开的模块
function create_block(bocks_div, block) {
    //添加block的div
    if ($("block_ids") != null && $("block_ids").innerHTML != "") {
        $("block_ids").innerHTML = $("block_ids").innerHTML + "," + block.id;
    } else {
        $("block_ids").innerHTML = block.id;
    }
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
        part_message.innerHTML += "<p>" + block.base_info.description + "</p>";
    }
    if (block.total_score != null && block.total_score != 0) {
        part_message.innerHTML += "<div class='fraction_h'>" + block.total_score + "分</div>";
    }
    b_div.appendChild(part_message);

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
        || (return_giving_time(block_start_hash.get(block.id)) >= return_giving_time(start) &&
            (block_end_hash.get(block.id) == "" ||
                return_giving_time(block_end_hash.get(block.id)) < return_giving_time(start))))))) {
        open_block_nav(block.id);
        block_block_flag = 1;
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
        b_start_time = sh + ":" + sm + ":00:00";
        if (time != "" && time != "0") {
            var total_m = h * 60 + m - new Number(time);
            h = (total_m >= 60) ? Math.floor(total_m/60) : 0;
            m = (total_m >= 60) ? new Number(total_m%60) : total_m;
            var eh = h < 10 ? ("0" + h) : h;
            var em = m < 10 ? ("0" + m) : m;
            end_time = eh + ":" + em + ":00:00";
        }
    }
    block_start_hash.set(block_id, b_start_time);
    block_end_hash.set(block_id, end_time);
}

//打开模块
function open_nav(block_id) {
    var block_ids = $("block_ids");
    if (block_ids != null && block_ids.innerHTML != "") {
        var b_ids = block_ids.innerHTML.split(",");
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
    start_block_audio(block_id);
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
    var sms = new Number(times[3]);
    return ss * 100 + sms;
}

//手动打开模块
function hand_open_nav(block_id) {
    if (is_fix_time) {
        var fs = return_giving_time(start);
        if ((block_end_hash.get(block_id) == null || block_end_hash.get(block_id) == "")) {
            var ss = return_giving_time(block_start_hash.get(block_id));
            if (ss < fs) {
                var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
                flash_div.innerHTML = "<p>当前部分还未可以开始答题。</p>";
                document.body.appendChild(flash_div);
                show_flash_div();
            } else {
                open_nav(block_id);
            }
        } else {
            var bs = return_giving_time(block_end_hash.get(block_id));
            if (bs < fs) {
                open_nav(block_id);
            } else {
                var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
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
function create_question_navigation(block_nav_div, question, problem_id) {
    var question_nav_li = create_element("li", null, "question_nav_"+question.id, null, null, "innerHTML");
    question_nav_li.innerHTML = "<a href='javascript:void(0);' id='a_que_nav_"+ question.id +"' onclick='javascript:get_question_height(\""+question.id+"\", \""+problem_id+"\");'><img src='/images/paper/kong.jpg' /></a>";
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
    if (question_ids != null) {
        var q_ids = question_ids.split(",");
        if (q_ids != null) {
            for (var j=0; j<q_ids.length; j++) {
                if (q_ids[j] == question_id) {
                    break;
                } else {
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
    var b_description_div = create_element("div", null, "b_description_" + problem.id, "part_div", null, "innerHTML");
    block_div.appendChild(b_description_div);
    var out_que_div = create_element("div", null, "question_" + problem.id, "part_question", null, "innerHTML");
    var score_str = "";
    if (problem.score != null && new Number(problem.score) != 0) {
        score_str = "<div class='fraction_h'>" + problem.score + "分</div>";
    }
    out_que_div.innerHTML = "<div class='part_q_text'><p>"+ is_has_audio(block_div, problem) + "</p>" + score_str +"</div>";
    b_description_div.appendChild(out_que_div);
    
    var question_id_input = create_element("input", "question_ids", "question_ids_" + problem.id, null, "hidden", "value");

    //    var que_inner_div = create_element("div", null, null, null, null, "innerHTML");
    //    out_que_div.appendChild(que_inner_div);
    //添加question所需div
    if (problem.questions != undefined && problem.questions.question != undefined) {
        var questions = problem.questions.question;
        if (tof(questions) == "array") {
            for (var j=0; j<questions.size(); j++) {
                create_question_navigation(block_nav_div, questions[j], problem.id);
                create_question(problem.id, question_id_input, out_que_div, questions[j], question_num);
                question_num ++ ;
            }
        } else {
            create_question_navigation(block_nav_div, questions, problem.id);
            create_question(problem.id, question_id_input, out_que_div, questions, question_num);
            question_num ++ ;
        }
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
function create_question(problem_id, question_id_input, parent_div, question, innerHTML) {
    $("all_question_ids").value += "" + question.id + ",";
    question_id_input.value += "" + question.id + ",";   
    parent_div.innerHTML += "<input type='hidden' name='question_type' id='question_type_"+ question.id +"' value='"+ question.correct_type +"'/>";
    //根据problem是否确定来判断question是否确定
    var question_is_sure = create_element("input", "question_sure", "question_sure_" + question.id, null, "hidden", "value");
    parent_div.appendChild(question_is_sure);
    var que_out_div = create_element("div", null, "que_out_" + question.id, "p_question_list", null, "innerHTML");
    que_out_div.innerHTML = "<div class='p_q_l_left'>" + innerHTML + "</div>";
    parent_div.appendChild(que_out_div);
    var single_question_div = create_element("div", null, "single_question_" + question.id, "p_q_l_right", null, "innerHTML");
    if (question.description != undefined) {
        single_question_div.innerHTML += "<div class='question_title'>" + question.description + "</div>";
    }
    que_out_div.appendChild(single_question_div);

    if (question.score != undefined && question.score != null && new Number(question.score) != 0) {
        var score_div = create_element("div", null, null, "fraction", null, "innerHTML");
        score_div.innerHTML = question.score + "分";
        que_out_div.appendChild(score_div);
    }
    que_out_div.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    create_single_question(problem_id, single_question_div, question);
}

function create_single_question(problem_id, que_div, question) {
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_attrs = question.questionattrs.split(";-;");
        var ul = create_element("ul", null, null, "chooseQuestion", null, "innerHTML");
        que_div.appendChild(ul);
        for (var i=0; i<que_attrs.length; i++) {
            if (que_attrs[i] != null && que_attrs[i] != "") {
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
    } else {
        var attr1 = create_element("div", null, null, "answer_textarea", null, "innerHTML");
        if (question.correct_type == "2") {  
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == "1") {
                attr1.innerHTML = "<br/><input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;";
            } else {
                attr1.innerHTML = "<br/><input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;";
            }
            
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id][0] == "0") {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />错/否&nbsp;&nbsp;";
            } else {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>错/否&nbsp;&nbsp;";
            }
        } else {
            if (question.correct_type == "3") {
                if (answer_hash != null && answer_hash[question.id] != null) {
                    attr1.innerHTML += "<br/><input type='text' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")' value='"+ answer_hash[question.id][0] +"' />";
                } else {
                    attr1.innerHTML += "<br/><input type='text' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")' />";
                }
            } else {
                if (answer_hash != null && answer_hash[question.id] != null) {
                    attr1.innerHTML += "<br/><textarea cols='35' rows='3' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'>"+ answer_hash[question.id][0] +"</textarea>";
                } else {
                    attr1.innerHTML += "<br/><textarea cols='35' rows='3' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'></textarea>";
                }
            }
            
        }
        que_div.appendChild(attr1);
    }
    
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
function show_exam_time() {
    // nextelapse是定时时间, 初始时为100毫秒
    // 注意setInterval函数: 时间逝去nextelapse(毫秒)后, onTimer才开始执行
    if (start != "00:00:00:00") {
        timer = window.setInterval("onTimer()", 1000);
    }
}

// 倒计时函数
function onTimer() {
    if (start == finish) {
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
    
    colse_or_open_block(current_time);
    // 清除上一次的定时器
    window.clearInterval(timer);
    // 启动新的定时器
    timer = window.setInterval("onTimer()", nextelapse);
}

//打开模块和关闭答案
function colse_or_open_block(current_time) {
    if (is_fix_time) {
        var has_close_block = false;
        var all_block_end_time = block_end_hash.values();
        for (var j=0; j<all_block_end_time.length; j++) {
            var block_title = $("b_title_" + block_end_hash.index(all_block_end_time[j])).innerHTML;
            if (all_block_end_time[j] == current_time) {
                var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
                flash_div.innerHTML = "<p> "+ block_title + " 部分答题时间已到，您的答案将自动被提交，请您继续做其它部分的题。</p>";
                document.body.appendChild(flash_div);
                show_flash_div();
                window.clearInterval(local_timer);
                local_storage_answer();
                has_close_block = true;
                break;
            } else if ((return_giving_time(current_time) - return_giving_time(all_block_end_time[j])) == 100*60) {
                flash_div.innerHTML = "<p>当前 "+block_title+" 部分剩余答题时间为1分钟，请您尽快答题，并提交答案。</p>";
                document.body.appendChild(flash_div);
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
                        || (return_giving_time(all_block_start_time[k]) >= return_giving_time(current_time) &&
                            (block_end_hash.get(block_id) == "" ||
                                return_giving_time(block_end_hash.get(block_id)) < return_giving_time(current_time)))) {
                        open_nav(block_id);
                        break;
                    }
                }
            }
        }
    }
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
function is_problem_answer(problem_id) {
    var answer_flag = "";
    var question_ids = $("question_ids_" + problem_id).value;
    if (question_ids != "") {
        var ids = question_ids.split(",");
        var is_answer_num = 0;
        for (var i=0; i<ids.length-1; i++) {
            var question_div = $("que_out_" + ids[i]);
            if (question_div != null) {
                var is_answer = question_value(ids[i]);
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
        $("a_que_nav_" + question_id).innerHTML = "<img src='/images/paper/yida.jpg' />";
    } else {
        $("que_out_" + question_id).className = "p_question_list question_no";
        $("a_que_nav_" + question_id).innerHTML = "<img src='/images/paper/buqueding.jpg' />";
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
function question_value(question_id) {
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
    } else {
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
                var answer = questions[i].getElementsByTagName("answer")[0].firstChild != null ?
                questions[i].getElementsByTagName("answer")[0].firstChild.data : "";
                answer_hash[questions[i].getAttribute("id")] = [answer, questions[i].getAttribute("is_sure")];
            }
        }
    }
}

//记录当前模块是否有听力
function is_has_audio(block_div, problem) {
    var block_id = block_div.id.split("block_nav_")[1];
    var titles = problem.title.split("<mp3>");
    var final_title = "";
    if (titles.length > 1) {
        var audio_str = "";
        if (window.HTMLAudioElement) {
            audio_str = "<audio id='audio_"+ block_id +"' onended='add_audio_cookies("+ block_id +");'>" +
            "<source src='"+ titles[1] +"' type='audio/mpeg'></audio>";
        } else {
            audio_str = "<object><embed id='audio_"+ block_id +"' src='"+ titles[1] +
            "' autostart='false' hidden='true' type='audio/midi'></object>";
        }
        final_title = audio_str + titles[2];
    } else {
        final_title = problem.title;
    }
    return final_title;
}

//当打开的模块有音频时，播放有音频
function start_block_audio(block_id) {
    if ($("audio_" + block_id) != null) {
        //                setCookie("exam_audio_" + block_id, 0);
        //                setCookie("audio_time_" + block_id, 0);
        var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
        if (getCookie("exam_audio_" + block_id) == null || getCookie("exam_audio_" + block_id) == 0) {
            flash_div.innerHTML = "<p>您当前打开的模块为听力模块，5秒钟后播放听力，请做好准备。</p>";
            document.body.appendChild(flash_div);
            show_flash_div();
            setTimeout(function(){
                control_audio(block_id);
            }, 10000);
        } else {
            flash_div.innerHTML = "<p>听力播放结束，请抓紧时间答题。</p>";
            document.body.appendChild(flash_div);
            show_flash_div();
        }
    }
}

//控制音频内容
var is_first_in = true;
function control_media(audio_id, types) {
    try {
        var audio = $("audio_" + audio_id);
        if (getCookie("audio_time_" + audio_id) != "end") {
            if(getCookie("exam_audio_" + audio_id) == null){
                setCookie("exam_audio_" + audio_id, 0);
            }
            if(new Number(getCookie("exam_audio_" + audio_id)) < 1){
                audio_timer = window.setInterval("audio_current_time('"+ audio_id +"', '"+ types +"')", 100);
                if (types == "audio") {
                    if(audio.paused){
                        if (getCookie("audio_time_" + audio_id) != null && new Number(getCookie("audio_time_" + audio_id)) != 0) {
                            audio.currentTime += getCookie("audio_time_" + audio_id);
                        }
                    }
                } else {
                    if (getCookie("audio_time_" + audio_id) != null) {
                        audio.currentPosition += getCookie("audio_time_" + audio_id);
                    }
                }
                audio.play();
            }
        }
    }catch (e) {
        var flash_div = create_element("div", null, "flash_notice", "tishi_tab", null, "innerHTML");
        flash_div.innerHTML = "<p>音频文件不能播放，请您检查您的音频文件是否存在。</p>";
        document.body.appendChild(flash_div);
        show_flash_div();
    }
}

//音频控制
var audio_timer = null;
function control_audio(audio_id) {
    if (window.HTMLAudioElement) {
        control_media(audio_id, "audio");
    } else {
        load_object_audio(audio_id);
    }
}

//不支持html5的浏览器使用
function load_object_audio(audio_id) {
    control_media(audio_id, "media");
}

//记录当前播放时间
function audio_current_time(audio_id, types) {
    if (new Number(getCookie("exam_audio_" + audio_id)) == 1) {
        window.clearInterval(audio_timer);
    } else {
        add_time_to_cookies(audio_id, types);
    }
    if (types == "media") {
        if (new Number(getCookie("audio_time_" + audio_id)) == 0 && is_first_in == false) {
            window.clearInterval(audio_timer);
            add_audio_cookies(audio_id);
        }
    }
}

//将音频播放的时间记录到cookie
function add_time_to_cookies(audio_id, types) {
    if (types == "audio") {
        if ($("audio_" + audio_id).currentTime != null) {
            setCookie("audio_time_" + audio_id, $("audio_" + audio_id).currentTime);
        }
    } else {
        if ($("audio_" + audio_id).currentPosition != null) {
            setCookie("audio_time_" + audio_id, $("audio_" + audio_id).currentPosition);
            if (new Number(getCookie("audio_time_" + audio_id)) > 0 && is_first_in) {
                is_first_in = false;
            }
        }
    }
    window.clearInterval(audio_timer);
    audio_timer = window.setInterval("audio_current_time('"+ audio_id +"', '"+ types +"')", 100);
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