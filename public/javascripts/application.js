// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function checkspace(checkstr){
    var str = '';
    for(var i = 0; i < checkstr.length; i++) {
        str = str + ' ';
    }
    if (str == checkstr){
        return true;
    }
    else{
        return false;
    }
}

function load_set_right(role_id){
    new Ajax.Updater("set_right_div", "/users/load_set_right",
    {
        asynchronous:true,
        evalScripts:true,
        method:"post",
        parameters:'role_id=' + role_id +'&authenticity_token=' + encodeURIComponent('kfCK9k5+iRMgBOGm6vykZ4ekez8CB77n9iApbq0omBs=')
    });
    return false;
}

function cancel_set_right(){
    $("set_right_div").innerHTML="";
    return false;
}