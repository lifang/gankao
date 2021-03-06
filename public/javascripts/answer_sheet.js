
// onmouseout则关闭
function mouseout_x( ae ){
    var e = window.event || ae;
    var s = e.toElement || e.relatedTarget;
    if(document.all){
        if( !this.contains(s) ){
            d1.style.display='none';
        }
    }else{
        var res= this.compareDocumentPosition(s) ;
        if( ! ( res == 20 || res == 0) ){
            d1.style.display='none';
        }
    }
}


//打开模块
function open_nav(block_id) {
    if(document.getElementById("upErrorTo_tab")!=null){
        document.getElementById("upErrorTo_tab").style.display='none';
    }
    if (jQuery('.biji_tab') != null) {
        jQuery('.biji_tab').css('display','none');
    }
    if (jQuery('.upErrorTo_tab') != null) {
        jQuery('.upErrorTo_tab').css('display','none');
    }
    if (jQuery('.jiexi_tab') != null) {
        jQuery('.jiexi_tab').css('display','none');
    }
    if (jQuery('.reason_tab') != null) {
        jQuery('.reason_tab').css('display','none');
    }
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
    if ($("next_block_" + block_id) != null) {
        $("next_block_" + block_id).style.display = "block";
    }
}

//关闭模块
function close_block_nav(block_id) {
    $("block_nav_" + block_id).className = "first_title";
    $("nav_block_" + block_id).style.display = "none";
    $("block_" + block_id).style.display = "none";
    if ($("next_block_" + block_id) != null) {
        $("next_block_" + block_id).style.display = "none";
    }
}

function get_question_height(question_id, problem_id) {
    var p_height = 0;
    var block_div = $("q_info_" + problem_id).parentNode;
    var all_divs = block_div.getElementsByTagName("div");
    if (all_divs != null) {
        for (var i=0; i<all_divs.length; i++) {
            if (all_divs[i].className == "part_div" || all_divs[i].className == "question_text_explain") {
                if (all_divs[i].id == "q_info_"+problem_id) {
                    break;
                } else {
                    p_height += all_divs[i].offsetHeight;
                }
            }
        }
    }
    var question_ids = $("question_ids_" + problem_id).value;
    p_height += $("problem_title_" + problem_id).offsetHeight;
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
        $("note_text_" + question_id).className='required validation-failed';
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
        cancel_note(note_question_info_id);
        if($("mp3_" + note_question_info_id) != null) {
            $("mp3_" + note_question_info_id).removeChild($("ele_" + note_question_info_id));
        }
    }
    document.getElementById("question_info_" + id).style.display = "block";
    document.getElementById("show_note_" + id).style.display = "none";
    document.getElementById("hidden_note_" + id).style.display = "block";
    if ($("mp3_" + id) != null) {
        var problem_title = $("mp3_value_" + id).value;
        var ele = document.createElement("div");
        ele.id = "ele_" + id;
        ele.innerHTML = generate_audio_element(id);
        $("mp3_" + id).appendChild(ele);
        generate_jplayer(problem_title, id);
    }
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

function audio_element(problem_title, flag_id) {
    var final_title = generate_audio_element(flag_id);
    document.write(final_title);
    generate_jplayer(problem_title, flag_id);
}


function generate_audio_element(flag_id) {
    var final_title = "<div id='jquery_jplayer_"+flag_id+"' class='jp-jplayer'></div>"
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

function generate_jplayer(problem_title, flag_id) {
    (function(){
        jQuery("#jquery_jplayer_"+flag_id).jPlayer({
            ready: function (event) {
                jQuery(this).jPlayer("setMedia", {
                    mp3:""+problem_title
                });
            },
            swfPath: "/javascripts/jplayer",
            supplied: "mp3",
            wmode: "window"
        });
    })(jQuery)
}

function droppable_element(problem_title, problem_id) {
    var place_num = 1;
    while(problem_title.indexOf("problem_" + problem_id + "_dropplace_" + place_num) >= 0){
        var store_id = "problem_" + problem_id + "_dropplace_" + place_num;
        $(store_id).style.cursor = 'Move';
        $(store_id).className = "task_span";
        Droppables.add(store_id, {
            onDrop:function(element,store_id){
                $(store_id).innerHTML = element.innerHTML;
                $(store_id).style.color = "#96AE89";
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
        if(user_answer[place_num - 1] == "" || user_answer[place_num - 1] == undefined){
            $("problem_" + problem_id + "_dropplace_" + place_num).innerHTML="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
        }
        else{
            $("problem_" + problem_id + "_dropplace_" + place_num).innerHTML = user_answer[place_num - 1];
        }
        if (answers[place_num - 1] == user_answer[place_num - 1]) {
            $("problem_" + problem_id + "_dropplace_" + place_num).className = "task_span correctRight_bg";
        } else {
            $("problem_" + problem_id + "_dropplace_" + place_num).className = "task_span red_bg";
        }
        place_num ++;
    }
}

function openwindow(id){
    var url = "/user/notes/" + id + "/show_dialog"; //转向网页的地址;
    var name = ""; //网页名称，可为空;
    var iWidth = "700"; //弹出窗口的宽度;
    var iHeight = "550"; //弹出窗口的高度;
    var iTop = (window.screen.availHeight-30-iHeight)/2; //获得窗口的垂直位置;
    var iLeft = (window.screen.availWidth-10-iWidth)/2; //获得窗口的水平位置;
    var this_window = window.open(url, name, "height="+ iHeight +", innerHeight="+ iHeight
        +", width="+ iWidth +", innerWidth="+ iWidth +", top="+ iTop +", left="+ iLeft
        +", 'toolbar=0, menubar=0, scrollbars=0, location=0, status=0'");
    this_window.document.clear();
    this_window.document.close();
    this_window.focus();
}

function generate_dialog_html(id) {
    var title = window.opener.document.getElementById("title_"+id).innerHTML;
    var answers = window.opener.document.getElementById("answer_" + id).innerHTML;
    var user_answers = window.opener.document.getElementById("user_answers_" + id).innerHTML;
    var audio_title = show_title_for_note(title, id);
    var final_title = audio_title.replace(/problem_x_dropplace/g, "problem_"+ id +"_dropplace");
    document.getElementById("content").innerHTML = final_title;
    replace_droppable_element(window, answers.replace(/<[^{><}]*>/g, ","), user_answers, id);
}



function show_title_for_note(title, id) {
    var titles = title.replace(/<\/mp3>/g, "").split("<mp3>");
    var audio_title = "";
    var leving_title = "";
    if (titles.length > 1) {
        audio_title = generate_audio_element(id);
        document.getElementById("problem_title").value = titles[1];
        leving_title = titles[0];
    } else {
        leving_title = titles;
    }
    return leving_title + audio_title;
}

function replace_droppable_element(this_window, answers, user_answers, problem_id) {
    var true_answers = answers.split(",");
    var user_answer = user_answers.split(",");
    var place_num = 1;
    while (this_window.document.body.innerHTML.indexOf("problem_" + problem_id + "_dropplace_" + place_num) >= 0) {
        if(user_answer[place_num - 1] == null || user_answer[place_num - 1] == "" || user_answer[place_num - 1] == undefined){
            this_window.document.getElementById("problem_" + problem_id + "_dropplace_" + place_num).innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
        } else {
            this_window.document.getElementById("problem_" + problem_id + "_dropplace_" + place_num).innerHTML = user_answer[place_num - 1];
        }
        if (true_answers[place_num - 1] == user_answer[place_num - 1]) {
            this_window.document.getElementById("problem_" + problem_id + "_dropplace_" + place_num).className = "task_span correctRight_bg";
        } else {
            this_window.document.getElementById("problem_" + problem_id + "_dropplace_" + place_num).className = "task_span red_bg";
        }
        place_num ++;
    }
}
