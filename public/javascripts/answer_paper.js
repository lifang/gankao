//加载试卷
function load_paper() {
//    if(window.openDatabase){
        setTimeout(function(){
            create_paper();
        }, 500);
//    } else {
//        create_paper();
//    }
}

//创建试卷
function create_paper() {
    //显示基本信息部分
    $("paper_title").innerHTML = papers.paper.base_info.title;
    $("paper_id").value = papers.paper.id;
    $("category_name").innerHTML = papers.paper.base_info.category_name;
    $("total_num").innerHTML = papers.paper.total_num;
    $("total_score").innerHTML = papers.paper.total_score;
    if (papers.paper.base_info.description != undefined) {
        $("description").innerHTML = papers.paper.base_info.description;
    }
    if (papers.paper.blocks != undefined && papers.paper.blocks.block != undefined) {
        var blocks = papers.paper.blocks.block;
        var bocks_div = $("blocks");
        if (tof(blocks) == "array") {
            for (var i=0; i<blocks.size();i++) {
                create_block(bocks_div, blocks[i]);
            }
        } else {
            create_block(bocks_div, blocks);
        }
    }
    show_exam_time();
    local_save_start(); 
}

//添加试卷块
function create_block(bocks_div, block) {
    //添加block的div
    var block_div = create_element("div", null, "block_" + block.id, null, null, "innerHTML");
    var block_str = "<h1 class='biz_art_title' id='block_show'>";
    block_str += block.base_info.title + "(共"+ block.total_num +"题，总分:"+ block.total_score +"分)</h1>";
    block_div.innerHTML = block_str;
    bocks_div.appendChild(block_div);
    var ul_div = create_element("div", null, null, "biz_art_list_box", null, "innerHTML");
    ul_div.innerHTML = block.base_info.description;
    block_div.appendChild(ul_div);
    var ul = create_element("ul", null, "ul_" + block.id, null, null, "innerHTML");
    ul_div.appendChild(ul);
    //判断problem的存在
    if (block.problems != undefined && block.problems.problem != undefined) {
        var problems = block.problems.problem;
        if (tof(problems) == "array") {
            for (var j=0; j<problems.size(); j++) {
                create_problem(ul, problems[j]);
            }
        } else {
            create_problem(ul, problems);
        }
    }
}
//添加problem
function create_problem(ul, problem) {
    var problem_li = create_element("li", null, "li_" + problem.id, null, null, "innerHTML");
    ul.appendChild(problem_li);
    var que_sup_parent_div = create_element("div", null, "question_info_" + problem.id, "products_list_style_box", null, "innerHTML");
    que_sup_parent_div.style.display = "none";
    que_sup_parent_div.innerHTML = "<div class='arrow' style='top:35px;'></div>";
    problem_li.appendChild(que_sup_parent_div);
    var que_parent_div = create_element("div", null, null, "big_pic_box", null, "innerHTML");
    que_sup_parent_div.appendChild(que_parent_div);

    var parent_div = create_element("div", null, "full_problem_" + problem.id, "in", null, "innerHTML");
    que_parent_div.appendChild(parent_div);
    var question_id_input = create_element("input", "question_ids", "question_ids_" + problem.id, null, "hidden", "value");
    parent_div.innerHTML = "<input type='hidden' name='problem_"+ problem.id +"' id='problem_"+ problem.id +"' value='"+ problem.id +"'/>";
    parent_div.innerHTML += "<div class='title'>"+ problem.title + "[" + problem.score +"分]</div>";
    //添加question所需div
    if (problem.questions != undefined && problem.questions.question != undefined) {
        var questions = problem.questions.question;
        if (tof(questions) == "array") {
            for (var j=0; j<questions.size(); j++) {
                create_question(question_id_input, parent_div, questions[j]);
            }
        } else {
            create_question(question_id_input, parent_div, questions);
        }
    }
    parent_div.appendChild(question_id_input);
    var is_answer_input = create_element("input", "is_answer", "is_answer_" + problem.id, null, "hidden", "value");
    parent_div.appendChild(is_answer_input);
    parent_div.innerHTML += "<input type='button' name='problem_submit' class='submit_btn' id='problem_submit' onclick='javascript:generate_problem_answer(\""+ problem.id +"\");' value='保存'/>";
    //追加problem的标题
    var problem_str = "<h2><a href='javascript:void(0)' onclick='javascript:question_info("+ problem.id +");'>"+ problem.title +"</a></h2>";
    problem_li.innerHTML += problem_str;
    $("problem_ids").value += "" + problem.id + ",";
    if (answer_hash != null) {
        load_problem_color(problem.id);
        alreay_answer_num();
    // answer_hash = null;
    }
//alert(parent_div.innerHTML);
}
//添加question所需div
function create_question(question_id_input, parent_div, question) {
    $("all_question_ids").value += "" + question.id + ",";
    question_id_input.value += "" + question.id + ",";
    var que_div = create_element("div", null, "question_" + question.id, "question", null, "innerHTML");
    que_div.innerHTML = "<input type='hidden' name='question_type' id='question_type_"+ question.id +"' value='"+ question.correct_type +"'/>小题";
    if (question.description != undefined) {
        que_div.innerHTML += "描述：" + question.description;
    }
    if (question.score != undefined) {
        que_div.innerHTML += "[" + question.score + "分]";
    } else {
        que_div.innerHTML += "[0分]";
    }
    parent_div.appendChild(que_div);
    create_single_question(que_div, question);
}

function create_single_question(que_div, question) {
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_attrs = question.questionattrs.split(";-;");
        for (var i=0; i<que_attrs.length; i++) {
            if (que_attrs[i] != null && que_attrs[i] != "") {
                var attr = create_element("div", null, null, "attr", null, "innerHTML");
                que_div.appendChild(attr);
                if (question.correct_type == "0") {
                    if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id] == que_attrs[i]) {
                        attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' checked='true' />";
                    } else {
                        attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"'/>";
                    }
                } else if (question.correct_type == "1") {
                    if (answer_hash != null &&  answer_hash[question.id] != null && answer_hash[question.id].split(";|;").include(que_attrs[i])) {
                        attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"' checked='true' />";
                    } else {
                        attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value='"+ que_attrs[i] +"'/>";
                    }
                    
                }
                attr.innerHTML += "<label>"+ que_attrs[i] +"</label>";
            }
        }
    } else {
        var attr1 = create_element("div", null, null, "attr", null, "innerHTML");
        if (question.correct_type == "2") {  
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id] == "1") {
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' checked='true' />对/是&nbsp;&nbsp;";
            } else {
                attr1.innerHTML = "<input type='radio' id='question_attr_1' name='question_attr_"+ question.id +"' value='1' />对/是&nbsp;&nbsp;";
            }
            
            if (answer_hash != null && answer_hash[question.id] != null && answer_hash[question.id] == "0") {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0' checked='true' />错/否&nbsp;&nbsp;";
            } else {
                attr1.innerHTML += "<input type='radio' id='question_attr_0' name='question_attr_"+ question.id +"' value='0'/>错/否&nbsp;&nbsp;";
            }
        } else {
            if (answer_hash != null && answer_hash[question.id] != null) {
                attr1.innerHTML += "<textarea cols='35' rows='3' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"'>"+ answer_hash[question.id] +"</textarea>";
            } else {
                attr1.innerHTML += "<textarea cols='35' rows='3' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"'></textarea>";
            }
        }
        que_div.appendChild(attr1);
    }
    if (question.tags != undefined && question.tags != null) {
        var tags = create_element("div", null, null, "tag", null, "innerHTML");
        tags.innerHTML = question.tags;
        que_div.appendChild(tags);
    }
    var answer_input = create_element("input", "answer_" + question.id, "answer_" + question.id, null, "hidden", "value");
    if (answer_hash != null && answer_hash[question.id] != null) {
        answer_input.value = answer_hash[question.id];
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

//返回题目的颜色
function load_problem_color(problem_id) {
    var problem_div = $("full_problem_" + problem_id);
    var question_ids = $("question_ids_" + problem_id).value;
    if (question_ids != "") {
        var ids = question_ids.split(",");
        var is_answer_num = 0;
        for (var i=0; i<ids.length-1; i++) {
            var question_div = $("question_" + ids[i]);
            if (question_div != null) {
                var is_answer = question_value(ids[i]);
                if (is_answer) {
                    is_answer_num++ ;
                }
            }
        }
        if (is_answer_num == (ids.length-1)) {
            $("li_" + problem_id).style.background = "#A3C6C8";
            problem_div.style.background = "#A3C6C8";
            $("is_answer_" + problem_id).value = "1";
        } else {
            $("li_" + problem_id).style.background = "#fff2f2";
            problem_div.style.background = "#fff2f2";
        }
    }
}

//用来返回问题是否已经回答
function generate_problem_answer(problem_id) {
    load_problem_color(problem_id);
    $("question_info_" + problem_id).style.display = "none";
    alreay_answer_num();
    save_problem(problem_id);
}

//使用本地存储保存答题的内容
function save_problem(problem_id) {
    if(window.openDatabase){
        var paper_id = $("paper_id").value;
        var examination_id = $("examination_id").value;
        var all_question_ids = $("question_ids_" + problem_id).value;
        if (all_question_ids != "") {
            var question_ids = all_question_ids.split(",");
            for (var i=0; i<question_ids.length-1; i++) {
                var answer = $("answer_" + question_ids[i]);               
                if (answer != null && !checkspace(answer.value)) {
                    remove_answer(question_ids[i], getCookie('user_id'), paper_id, examination_id);
                    add_answer(question_ids[i], getCookie('user_id'), paper_id, examination_id, answer.value);
                }
            }
        }       
    }
}

//用来返回考生已经答完多少题了
function alreay_answer_num() {
    var total_num = 0;
    var problem_ids = $("problem_ids").value;
    if (problem_ids != null && problem_ids != "") {
        var ids_arr = problem_ids.split(",");
        for (var i=0; i<ids_arr.length; i++) {
            var problem_is_answer = $("is_answer_" + ids_arr[i]);
            if (problem_is_answer != null && problem_is_answer.value == "1") {
                total_num ++;
            }
        }
        $("complete_num").innerHTML = total_num;
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
    var questions = xmlDom.getElementsByTagName("question");
    if (questions.length > 0) {
        answer_hash = new Hash();
        for(var i=0;i<questions.length;i++){
            answer_hash[questions[i].getAttribute("id")] = questions[i].firstChild.firstChild.nodeValue;
        }
    }
}


