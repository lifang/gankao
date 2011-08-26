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

function check_note_form(question_id) {
    if (checkspace($("note_text_" + question_id).value)) {
        return false;
    }
    return true;
}

close_question_info_id = 0;
//显示题目
function note_question_info(id){
    if(close_question_info_id != 0 && close_question_info_id != id){
        document.getElementById("question_info_" + close_question_info_id).style.display = "none";
    }
    document.getElementById("question_info_" + id).style.display = "block";
    close_question_info_id = id;
}