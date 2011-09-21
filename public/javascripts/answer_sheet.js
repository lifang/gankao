//打开模块
function open_nav(block_id) {
    jQuery('.biji_tab').css('display','none');
    jQuery('.jiexi_tab').css('display','none');
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
}

//关闭模块
function close_block_nav(block_id) {
    $("block_nav_" + block_id).className = "first_title";
    $("nav_block_" + block_id).style.display = "none";
    $("block_" + block_id).style.display = "none";
}

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
                    if ($("question_info_" + p_ids[i]) != null) {
                        p_height += $("question_info_" + p_ids[i]).offsetHeight;
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

function check_note_form(question_id) {
    if (checkspace($("note_text_" + question_id).value)) {
        return false;
    }
    return true;
}

note_question_info_id = 0;
//显示题目
function note_question_info(id){
    if(note_question_info_id != 0 && note_question_info_id != id){
        document.getElementById("question_info_" + note_question_info_id).style.display = "none";
        document.getElementById("show_note_" + note_question_info_id).style.display = "block";
        document.getElementById("hidden_note_" + note_question_info_id).style.display = "none";
    }
    document.getElementById("question_info_" + id).style.display = "block";
    document.getElementById("show_note_" + id).style.display = "none";
    document.getElementById("hidden_note_" + id).style.display = "block";
    note_question_info_id = id;
}

function cancel_note(question_id) {
    $("start_note_" + question_id).style.display = "none";
    $("note_" + question_id).style.display = "block";
}

function update_note(question_id) {
    $("start_note_" + question_id).style.display = "block";
    $("note_" + question_id).style.display = "none";
}

function audio_element(problem_title) {
    var final_title = "";
    if (window.HTMLAudioElement) {
        final_title = "<audio id='audio' controls='controls'><source src='"+ problem_title +
        "' type='audio/mpeg'></audio>";
    } else {
        final_title = "<object><embed id='audio' src='"+ problem_title +
        "' autostart='false' type='audio/midi'></object>";
    }
    document.write(final_title);
}

function droppable_element(problem_title, problem_id) {  
    var place_num = 1;
    while(problem_title.indexOf("problem_" + problem_id + "_dropplace_" + place_num) >= 0){
        var store_id = "problem_" + problem_id + "_dropplace_" + place_num;
        $(store_id).style.cursor = 'Move';
        Droppables.add(store_id, {
            onDrop:function(element,store_id){
                $(store_id).innerHTML = element.innerHTML;
                $(store_id).style.color = "blue";
            }
        })
        place_num ++;
    }
}

function droppable_result(true_answers, user_answers, problem_id) {
    var answers = true_answers.split(",");
    var user_answer = user_answers.split(",");
    var str = $("question_info_" + problem_id).innerHTML;
    var place_num = 1;
    while (str.indexOf("problem_" + problem_id + "_dropplace_" + place_num) >= 0) {
        $("problem_" + problem_id + "_dropplace_" + place_num).innerHTML = user_answer[place_num - 1];
        if (answers[place_num - 1] == user_answer[place_num - 1]) {
            $("problem_" + problem_id + "_dropplace_" + place_num).style.color = "blue";
        } else {
            $("problem_" + problem_id + "_dropplace_" + place_num).style.color = "red";
        }
        place_num ++;
    }
}

function openwindow(id){
    var url = ""; //转向网页的地址;
    var name = ""; //网页名称，可为空;
    var iWidth = "600"; //弹出窗口的宽度;
    var iHeight = "450"; //弹出窗口的高度;
    var iTop = (window.screen.availHeight-30-iHeight)/2; //获得窗口的垂直位置;
    var iLeft = (window.screen.availWidth-10-iWidth)/2; //获得窗口的水平位置;
    var this_window = window.open(url, name, "height="+ iHeight +", innerHeight="+ iHeight
        +", width="+ iWidth +", innerWidth="+ iWidth +", top="+ iTop +", left="+ iLeft
        +", 'toolbar=0, menubar=0, scrollbars=0, location=0, status=0'");
    this_window.document.clear();
    this_window.document.close();
    var title = this_window.opener.document.getElementById("title_"+id).value;
    this_window.document.write(title);
    this_window.focus();
}