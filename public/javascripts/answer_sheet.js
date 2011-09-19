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