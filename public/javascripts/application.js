// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery

//= require_tree .


function checkDate(id){
    if(!__$(id).value.trim().match(/^\d{4}\-((0[1-9])|(1[0-2]))\-(([0-2][0-9])|(3[0-1]))$|^$/)){
        __$(id).style.color = "red";
        __$(id + "_lbl").style.color = "red";
    } else if(__$(id).value.trim().match(/^\d{4}\-((0[1-9])|(1[0-2]))\-(([0-2][0-9])|(3[0-1]))$|^$/)){
        var d = new Date(__$(id).value.trim());

        if(isNaN(d.getFullYear())){
            __$(id).style.color = "red";
            __$(id + "_lbl").style.color = "red";
        } else {
            __$(id).style.color = "green";
            __$(id + "_lbl").style.color = "green";
        }

    } else {
        __$(id).style.color = "black";
        __$(id + "_lbl").style.color = "black";
    }

    setTimeout("checkDate('" + id + "')", 100);

}

function checkIfNumber(id){
    if(__$(id)){

        if(!__$(id).value.trim().match(/^\d+(\.\d+)?$/)){
            __$(id).style.color = "red";
            __$(id + "_lbl").style.color = "red";
        } else {
            __$(id).style.color = "black";
            __$(id + "_lbl").style.color = "black";
        }

        setTimeout("checkIfNumber('" + id + "')", 100);

    }
}

function highlight(id, conditional){
    if(__$(id) ){

        if(conditional){
            __$(id).style.color = "red";
            __$(id + "_lbl").style.color = "red";
        } else {
            __$(id).style.color = "black";
            __$(id).style.color = "black";
        }

    }
}

function isInt(n){
    return typeof n== "number" && isFinite(n) && n%1===0;
}