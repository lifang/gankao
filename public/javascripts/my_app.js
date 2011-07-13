function check_new(){ 
    var username=document.getElementById("user_name").value;
    var strEmail=document.getElementById("user_email").value;
    var password=document.getElementById("user_password").value;
    var confirmation=document.getElementById("user_password_confirmation").value;
    var myReg =new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    var check_value = new RegExp(/[a-z0-9_]/g);
    var strEmail=document.getElementById("user_email").value;
    if (strEmail == null || strEmail.length ==0||strEmail.length>50){
        document.getElementById("emailErr").innerHTML="<font color = 'red'>邮箱不能为空，长度不能超过50</font>";
        return false;
    } else {
        if ( myReg.test(strEmail)) {
            document.getElementById("emailErr").innerHTML="";
        } else{
            document.getElementById("emailErr").innerHTML="<font color = 'red'>邮箱格式不对，请重新输入！</font>";
            return false;
        }
    }
    
    if (password == null || password.length ==0||password.length>40||password.length<6){

        document.getElementById("passwordErr").innerHTML="<font color = 'red'>密码不能为空，长度在6和20之间</font>";
        return false;
    } else	{
        document.getElementById("passwordErr").innerHTML="";
        if (confirmation != password){

            document.getElementById("confirmationErr").innerHTML="<font color = 'red'>两次输入的密码不一致，请重新输入</font>";
            return false;
        }else{
            document.getElementById("confirmationErr").innerHTML="";
        }
    }
    if (username == null || username.length ==0||username.length>30){
        document.getElementById("usernameErr").innerHTML="<font color = 'red'>用户名不能为空，长度不能超过30</font>";
        return false;
    }else{
        if (check_value.test(username)) {
            document.getElementById("usernameErr").innerHTML="";
        } else{
            document.getElementById("usernameErr").innerHTML="<font color = 'red'>用户名只能由字母，数字和下划线组成</font>";
            return false;
        }
    }
    alert(0);
}

function signin_page(){
    var check_value =new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    var user_name= document.getElementById("session_email").value;
    var user_password= document.getElementById("session_password").value;
    if (user_name == null||user_name.length==0|| check_value.test(user_name)==false){
        document.getElementById("error_msg").style.color="#FF0000"
        document.getElementById("error_msg").innerHTML="请输入邮箱或格式不正确";
        return false;
    }
    else {
        document.getElementById("error_msg").innerHTML="";
        if(user_password == null||user_password.length==0){
            document.getElementById("error_msg").style.color="#FF0000"
            document.getElementById("error_msg").innerHTML="请输入正确的密码";
            return false;
        }
    }
}

function tab(tag, n){
    for(var i=1; i <= n; i++){
        document.getElementById("li_tab" + i).className = "";
        document.getElementById("div_tab" + i).className = "";
    }
    document.getElementById("li_" + tag).className = "actived";
    document.getElementById("div_" + tag).className = "actived";

}
