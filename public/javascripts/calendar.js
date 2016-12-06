
var current_date = new Date();
var calendarTarget = null;

function __$(id){
    return document.getElementById(id);
}

function checkCtrl(obj){
    var o = obj;
    var t = o.offsetTop;
    var l = o.offsetLeft + 1;
    var w = o.offsetWidth;
    var h = o.offsetHeight;

    while((o ? (o.offsetParent != document.body) : false)){
        o = o.offsetParent;
        t += (o ? o.offsetTop : 0);
        l += (o ? o.offsetLeft : 0);
    }
    return [w, h, t, l];
}

function padZeros(number, positions){
    var zeros = parseInt(positions) - String(number).length;
    var padded = "";

    for(var i = 0; i < zeros; i++){
        padded += "0";
    }

    padded += String(number);

    return padded;
}

function navBack(){
    if(__$("month").selectedIndex > 0){
        __$("month").selectedIndex -= 1;
        generateDays();
    } else {
        if(__$("year").selectedIndex - 1 >= 0){
            __$("year").selectedIndex -= 1;
            __$("month").selectedIndex = 11;
        }
    }
}

function navNext(){
    if(__$("month").selectedIndex < 11){
        __$("month").selectedIndex += 1;
        generateDays();
    } else {
        if(__$("year").selectedIndex + 1 < __$("year").options.length){
            __$("year").selectedIndex += 1;
            __$("month").selectedIndex = 0;
        }
    }
}

function loadCalendar(control, minYr, maxYr, topAlign, leftAlign){
    
    if(__$("calendarContainer")){
        document.body.removeChild(__$("calendarContainer"));
        return;
    }

    calendarTarget = control;

    var mdate = __$(control).value.match(/(\d{4})-(\d{2})-(\d{2})/);

    if(!mdate){
        var today = new Date();
    
        mdate = ["Today", today.getFullYear(), today.getMonth() + 1, today.getDate()];
    }

    var pos = checkCtrl(__$(control));
    // w, h, t, l

    var tbl = document.createElement("div");
    tbl.id = "calendarContainer";
    tbl.style.display = "table";
    tbl.style.position = "absolute";
    tbl.style.border = "1px solid #ccc";
    tbl.style.backgroundColor = "#999";
    tbl.style.borderRadius = "10px";
    tbl.style.padding = "10px";

    var w = 536, h = 392;
    
    if(pos[2] < h){
        topAlign = true;
    }

    if(topAlign){
        tbl.style.top = (pos[2] + pos[1]) + "px";
    } else {
        tbl.style.top = (pos[2] - h) + "px";
    }

    if(leftAlign){
        tbl.style.left = pos[3] + "px";
    } else {
        tbl.style.left = (pos[3] + pos[0] - w) + "px";
    }

    document.body.appendChild(tbl);

    var row1 = document.createElement("div");
    row1.style.display = "table-row";

    tbl.appendChild(row1);

    var row2 = document.createElement("div");
    row2.style.display = "table-row";

    tbl.appendChild(row2);

    var cell1_1 = document.createElement("div");
    cell1_1.style.display = "table-cell";

    row1.appendChild(cell1_1);

    var tblBanner = document.createElement("div");
    tblBanner.style.display = "table";
    tblBanner.style.width = "100%";

    cell1_1.appendChild(tblBanner);

    var rowBanner = document.createElement("div");
    rowBanner.style.display = "table-row";

    tblBanner.appendChild(rowBanner);

    var cellBanner1_1 = document.createElement("div");
    cellBanner1_1.style.display = "table-cell";

    rowBanner.appendChild(cellBanner1_1);

    var cellBanner1_2 = document.createElement("div");
    cellBanner1_2.style.display = "table-cell";
    cellBanner1_2.style.textAlign = "center";

    rowBanner.appendChild(cellBanner1_2);

    var cellBanner1_3 = document.createElement("div");
    cellBanner1_3.style.display = "table-cell";
    cellBanner1_3.style.textAlign = "center";

    rowBanner.appendChild(cellBanner1_3);

    var cellBanner1_4 = document.createElement("div");
    cellBanner1_4.style.display = "table-cell";
    cellBanner1_4.style.textAlign = "right";

    rowBanner.appendChild(cellBanner1_4);

    var back = document.createElement("input");
    back.type = "button";
    back.style.fontSize = "18px";
    back.style.padding = "10px";
    back.style.cursor = "pointer";
    back.value = "<<";

    back.onclick = function(){
        navBack();
    }

    cellBanner1_1.appendChild(back);

    var next = document.createElement("input");
    next.type = "button";
    next.style.fontSize = "18px";
    next.style.padding = "10px";
    next.style.cursor = "pointer";
    next.value = ">>";

    next.onclick = function(){
        navNext();
    }

    cellBanner1_4.appendChild(next);

    var month = document.createElement("select");
    month.id = "month";
    month.style.fontSize = "18px";
    month.style.padding = "10px";
    month.onchange = function(){
        generateDays();
    }

    cellBanner1_2.appendChild(month);

    var months = ["January", "February", "March", "April", "May",
    "June", "July", "August", "September", "October", "November", "December"];

    for(var i = 0; i < months.length; i++){
        var opt = document.createElement("option");
        opt.innerHTML = months[i];

        if(mdate){
            var p = eval(mdate[2]) - 1;

            if(i == p){
                opt.setAttribute("selected", "selected");
            }
        }

        month.appendChild(opt);
    }

    var year = document.createElement("select");
    year.id = "year";
    year.style.fontSize = "18px";
    year.style.padding = "10px";
    year.onchange = function(){
        generateDays();
    }

    cellBanner1_3.appendChild(year);

    for(var i = 0; i < (maxYr - minYr); i++){
        var opt = document.createElement("option");
        opt.innerHTML = minYr + i;

        if(mdate){
            var p = parseInt(mdate[1]);

            if((minYr + i) == p){
                opt.setAttribute("selected", "selected");
            }
        }

        year.appendChild(opt);
    }

    var cell2_1 = document.createElement("div");
    cell2_1.id = "parent";
    cell2_1.style.display = "table-cell";

    row2.appendChild(cell2_1);

    generateDays();
}

function generateDays(){

    if(__$("calendar")){
        __$("parent").removeChild(__$("calendar"));
    }

    var year = "year";
    var month = "month";

    var calendar = document.createElement("div");
    calendar.id = "calendar";
    calendar.style.width = "98%";

    __$("parent").appendChild(calendar);

    var keyboard = document.createElement("div");
    keyboard.style.margin = "auto";
    keyboard.style.display = "table";
    keyboard.style.backgroundColor = "#ccc";
    keyboard.style.borderRadius = "10px";
    keyboard.style.borderSpacing = "3px";

    calendar.appendChild(keyboard);

    var months = {
        "January":[31, 0],
        "February":[(parseInt(__$(year).value) % 4 > 0 ? 28 : 29), 1],
        "March":[31, 2],
        "April":[30, 3],
        "May":[31, 4],
        "June":[30, 5],
        "July":[31, 6],
        "August":[31, 7],
        "September":[30, 8],
        "October":[31, 9],
        "November":[30, 10],
        "December":[31, 11]
    }

    var date = new Date(parseInt(__$(year).value), parseInt(months[__$(month).value][1]), 1);

    var row1 = document.createElement("div");
    row1.style.display = "table-row";

    keyboard.appendChild(row1);

    var days = ["S", "M", "T", "W", "T", "F", "S"];

    var today = new Date();

    for(var d = 0; d < days.length; d++){
        var day = document.createElement("div");
        day.style.display = "table-cell";
        day.style.padding = "15px";
        day.style.borderRadius = "5px";
        day.style.textAlign = "center";
        day.style.backgroundColor = "#666";
        day.style.color = "#eee";
        day.innerHTML = days[d];

        row1.appendChild(day);
    }

    var p = date.getDay();
    var count = 1;

    for(var w = 0; w <= 6; w++){
        var row = document.createElement("div");
        row.style.display = "table-row";

        keyboard.appendChild(row);

        for(var d = 0; d < days.length; d++){
            var day = document.createElement("div");
            day.style.display = "table-cell";

            if((p == d || count > 1) && count <= months[__$(month).value][0]){
                // day.innerHTML = count;
                var btn = document.createElement("button");
                btn.innerHTML = count;
                btn.style.fontSize = "18px";
                btn.style.padding = "10px";
                btn.style.cursor = "pointer";
                // btn.className = "keyboard_button blue";
                btn.style.minWidth = "70px";

                if(count == today.getDate() && parseInt(__$(year).value) == today.getFullYear() &&
                    parseInt(months[__$(month).value][1]) == today.getMonth()){

                    btn.style.backgroundColor = "rgb(192, 0, 0)";
                    btn.style.color = "#fff";
                    
                }

                btn.onmousedown = function(){
                    __$(calendarTarget).value = __$("year").value + "-" +
                    padZeros((__$("month").selectedIndex + 1), 2) + "-" +
                    padZeros(this.innerHTML, 2);

                    document.body.removeChild(__$("calendarContainer"));
                }

                btn.onkeydown = function(event){
                    if (event.keyCode == 13)
                        document.getElementById('next').click()
                }

                day.appendChild(btn);

                p++;
                count++;
            }

            row.appendChild(day);
        }

    }

}

if (document.getElementsByTagName) {

    var inputElements = document.getElementsByTagName("input");

    for (i=0; inputElements[i]; i++) {

        if (inputElements[i].className && (inputElements[i].className.indexOf("disableAutoComplete") != -1)) {

            inputElements[i].setAttribute("autocomplete","off");

        }

    }

}