// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function check_paper_search_form() {
    
}

function get_category_value(field) {
   for (var i=0; i<field.length; i++) {
      if(field[i].selected == true) {
        $("category_name").value = field[i].text;
      }
   }
}

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

function sumbit_form(form_id, button_id, pic_id) {
    var valid = new Validation(''+form_id, {onSubmit:false});
    var result = valid.validate();
    if (!result) {
      $(""+pic_id).hide();
      $(""+button_id).show();
      return false;
    }
    $(""+pic_id).show();
    $(""+button_id).hide();
}

