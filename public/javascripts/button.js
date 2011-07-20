//验证注册按钮
function buttoncontrol(){  
    var sles=document.getElementsByName("checkbox");
    var all=document.getElementById("submit_button");
    all.className="reg_btn";
    for (var k=0;k<sles.length;k++) {
        if (sles[k].checked){
            all.className="reg_btn";
            document.getElementById("submit_button").disabled=false;
        } else {
            all.className="reg_btn_no";
            document.getElementById("submit_button").disabled=true;
        }
    }
}



