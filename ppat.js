var xmlDoc;
var powerCase;
var powerComponent;
var performanceCase;
var powerDevice;
var deviceComponent;
var boardDevice;
var testcases="";
function ppat_load(buildtype){
    var strURL = "http://10.38.32.97:3000/scenarios";
            $.ajax({
              type: "GET",
              url: strURL,
                timeout:3000,
                dataType:'html',
              success: function(msg){
                    powerCase = new Array();
                    powerComponent = new Array();
                    performanceCase = new Array();
                    powerDevice = new Array();
                    deviceComponent = new Array();
                    boardDevice = new Array();
                    domParser = new DOMParser();
                    xmlDoc = domParser.parseFromString(msg, 'text/xml');
                    ppat_parsePowerNode();
                    ppat_parsePerformanceNode();
                    ppat_parseDeviceNode();
                    ppat_parseBoardDevice();
                    generateUI(buildtype);
                    ppat_load_testcase();

                    $(".1080p").colorbox({inline:true, width:"50%"});
                    $(".720p").colorbox({inline:true, width:"50%"});
                    $(".VGA").colorbox({inline:true, width:"50%"});
                    $(".mp3").colorbox({inline:true, width:"50%"});
                    $(".1080p_wfd").colorbox({inline:true, width:"50%"});
                    $(".720p_wfd").colorbox({inline:true, width:"50%"});
                    $(".VGA_wfd").colorbox({inline:true, width:"50%"});
              }
            });
}

function ppat_update_checkbox(id,stream, duration){
    $("#"+id).attr("checked",true);
    testcases += "{\"CaseName\":\"" + id + "\",";
    testcases += "\"Stream\":\"" + stream + "\",";
    testcases += "\"Duration\":\"" + duration + "\"},";
}


function ppat_load_testcase(){
    var audioURL = "http://10.38.32.97:3000/tc/audio";
    $.ajax({
        type: "GET",
        url: audioURL,
        timeout:3000,
        dataType:'html',
        success: function(data){
             var audio_xml = new DOMParser().parseFromString(data, 'text/xml');
             $(audio_xml).find('Resource').each(function(i){
                  var audio = '<input align=\"left\" onclick=ppat_update_checkbox(\"mp3\",\"'+ $(this).find("Name").text() + '\",\"'+ $(this).find("Duration").text() +'\") type=\"radio\" name=\"testcase_audio\" value=\"testcase_audio\">'+ $(this).find("Name").text() + '</input></br>';
                  audio +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Duration:' + '</b>' +$(this).find("Duration").text() + 's</div>';
                  audio +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Description:' + '</b>' +$(this).find("Description").text() +'</div>';

                  $("#mp3").append(audio);
            });

        }
    });
    var videoURL = "http://10.38.32.97:3000/tc/video";
    $.ajax({
        type: "GET",
        url: videoURL,
        timeout:3000,
        dataType:'html',
        success: function(msg){
             var video_xml = new DOMParser().parseFromString(msg, 'text/xml');
             $(video_xml).find('Resource').each(function(i){
                 var checkbox = '<input onclick=ppat_update_checkbox(\"' + $(this).find("CaseName").text() + '\",\"'+ $(this).find("Name").text() + '\",\"'+ $(this).find("Duration").text() +'\")  type=\"radio\" name=\"testcase\" value=\"testcase\">'+ $(this).find("Name").text() + '</input></br>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>FPS:' + '</b>' +$(this).find("FPS").text() + '</div>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Duration:' + '</b>' +$(this).find("Duration").text() + 's</div>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Description:' + '</b>' + $(this).find("Description").text() + '</div>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"}><b>Description:' + '</b>' + $(this).find("StreamModule").text() + '</div>';
                 $("#" + $(this).find("CaseName").text()).append(checkbox);
            });
        }
    });

}

function ppat_parseBoardDevice(){
    var nodes = xmlDoc.getElementsByTagName("Board");
    for(i = 0; i < nodes.length; i++){
        var str = "{";
        str += "\"type\":\"" + nodes[i].getElementsByTagName("Type")[0].firstChild.nodeValue + "\",";
        var hw = nodes[i].getElementsByTagName("Name");
        var modules = new Array();
        for(j = 0; j < hw.length; j++){
            modules.push(hw[j].firstChild.nodeValue);
        }
        str += "\"hw\":\"" + modules.join(";") + "\"";
        str += "}";
        boardDevice.push(eval('(' + str + ')'));
    }
}

function ppat_parseDeviceNode(){
    var nodes = xmlDoc.getElementsByTagName("Device");
    for(i = 0; i < nodes.length; i++){
        var str = "{";
        str += "\"name\":\"" + nodes[i].getElementsByTagName("Name")[0].firstChild.nodeValue + "\",";
        var testcases = nodes[i].getElementsByTagName("CaseName");
        var cases = new Array();
        for(j = 0; j < testcases.length; j++){
            cases.push(testcases[j].firstChild.nodeValue);
            powerComponent.push(testcases[j].getAttribute("Component"));
            deviceComponent.push(testcases[j].getAttribute("Component"));
        }
        str += "\"TestCase\":\"" + cases + "\"";
        str += "}";
        powerDevice.push(eval('(' + str + ')'));
    }
}

function ppat_parsePowerNode(){
    var nodes = xmlDoc.getElementsByTagName("Power");

    for(i = 0; i < nodes.length; i++){
        caseName = nodes[i].getElementsByTagName("CaseName")[0].firstChild.nodeValue;
        component = nodes[i].getElementsByTagName("Component")[0].firstChild.nodeValue;
        powerCase.push(caseName);
        powerComponent.push(component);
    }
}

function ppat_parsePerformanceNode(){
    var nodes = xmlDoc.getElementsByTagName("Performance");

    for(i = 0; i < nodes.length; i++){
        caseName = nodes[i].getElementsByTagName("CaseName")[0].firstChild.nodeValue;
        performanceCase.push(caseName);
    }
}

function generateUI(buildtype){

    var submit;
    if(buildtype == "ppat_test"){
        $("#odvb_ppat").html("");
        $("#org_ppat").html("");
        submit = document.getElementById("org_ppat");
    }else {
        $("#org_ppat").html("");
        $("#odvb_ppat").html("");
        submit = document.getElementById("odvb_ppat");
    }
    var colorbox = "<div style='display:none'>" +
                                     "<div id='1080p' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='720p' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='VGA' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='mp3' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">audio</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='1080p_wfd' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='720p_wfd' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='VGA_wfd' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div></div>";

    var label = document.createElement("label");
    label.id="DeviceHW";
    label.name="powerdevice";
    label.innerHTML="<b>Choose Board HW Module:</b>";
    label.style.display = "none";
    submit.insertBefore(label, null);
    ppat_addhr(submit);
    $("#DeviceHW").append(colorbox);

    label = document.createElement("label");
    label.id="power";
    label.name="power";
    label.innerHTML="<b>Power Consumption Test:</b>";

    submit.insertBefore(label, null);
    ppat_addBr(submit);
    for(var i = 0; i < powerCase.length; i++){
        ppat_addCheckbox(submit, "power", powerCase[i], powerComponent[i]);
    }

    var div = document.createElement("div");
    div.id="power_device";
    submit.insertBefore(div, null);

    var button = document.createElement("input");
    button.type="button";
    button.name="Button_SelectAll";
    button.onclick= function(){ ppat_CheckboxSelectAll('power');};
    button.value="Select All";
    submit.insertBefore(button, null);
    button = document.createElement("input");
    button.type="button";
    button.name="Button_ClearAll";
    button.onclick=function(){ ppat_CheckboxSelectClear('power');};
    button.value="Clear ALL";
    submit.insertBefore(button, null);
    powerComponent = powerComponent.del();
    for(var i = 0; i < powerComponent.length; i++){
        var buttons = document.createElement("input");
        buttons.type="button";
        buttons.name=powerComponent[i];
        buttons.onclick=(function(n){ return function(){ppat_CheckboxSelectComponent('power', powerComponent[n]);}})(i);
        buttons.value="Choose " + powerComponent[i];
        submit.insertBefore(buttons, null);
    }

    ppat_addBr(submit);

    label = document.createElement("label");
    label.id="power_adv";
    label.name="poweradv";
    label.innerHTML="<b>Advanced Power Consumption Test:</b>";
    label.style.display = "none";
    submit.insertBefore(label, null);

    var advanced_tc = document.getElementById("power_adv");
    advanced_tc.style.display="none";
    var advanced = document.createElement("div");
    advanced.id="advanced_power";
    advanced_tc.insertBefore(advanced, null);

    $(xmlDoc).find("PowerAdvanced").each(function(i, ele){
        $(this).children("Platform").each(function(i){
            ppat_addCheckbox(advanced_tc,"power", $(ele).children("CaseName").text(), "video");
        });
    });

    var label = document.createElement("label");
    label.id="power";
    label.name="power";
    label.innerHTML="<b>UI Performance Test:</b>";

    submit.insertBefore(label, null);
    ppat_addBr(submit);

    for(var i = 0; i < performanceCase.length; i++){
        ppat_addCheckbox(submit,"performance", performanceCase[i]);
    }
    ppat_addBr(submit);
    button = document.createElement("input");
    button.type="button";
    button.name="Button_SelectAll";
    button.onclick= function(){ ppat_CheckboxSelectAll('performance');};
    button.value="Select All";
    submit.insertBefore(button, null);
    button = document.createElement("input");
    button.type="button";
    button.name="Button_ClearAll";
    button.onclick=function(){ ppat_CheckboxSelectClear('performance');};
    button.value="Clear ALL";
    submit.insertBefore(button, null);
    powerComponent = powerComponent.del();

    ppat_addBr(submit);
    ppat_addhr(submit);
    label = document.createElement("label");
    label.id="power";
    label.name="power";
    label.innerHTML="<b>Please input some special commands before run each case:</b>";

    submit.insertBefore(label, null);
    ppat_addBr(submit);
    var textarea = document.createElement("textarea");
    textarea.cols = 60;
    textarea.rows = 10;
    textarea.id = "ppat_testarea";

    submit.insertBefore(textarea, null);

    ppat_addBr(submit);
    ppat_addhr(submit);
/*
//remove the "add ppat to textfield button"
    button = document.createElement("input");
    button.type="button";
    button.name="Add to PPAT Test TextField";
    button.onclick=function(){ ppat_appendToText("property3value");};
    button.value="Add to PPAT Test TextField";
    submit.parentNode.appendChild(button, submit);
*/
//  }
}

function ppat_appendToText(v){
    xmlvalue = v;
    var chks = document.getElementsByTagName("input");
    var jsonStr = "";
    var textfiled;
    var caseCount = 0;
       for (var i = 0; i < chks.length; i++) {
     if (chks[i].type == "checkbox" && chks[i].checked) {
        if(chks[i].nextSibling.nodeValue != "" && chks[i].nextSibling.nodeValue != null){
            caseCount += 1;
            jsonStr += "{\"Name\":\"" + chks[i].nextSibling.nodeValue + "\"},";
        }
         }
    if(chks[i].name == xmlvalue){
        textfiled = chks[i];
         }
    }
    if(caseCount >= 1){
        jsonStr = "{\"TestCaseList\":[" + jsonStr.substring(0, jsonStr.length - 1) + "]";
        var text = document.getElementById("ppat_testarea").value;
        if(text != ""){
            jsonStr +=",\"inputs\":\"" + text.replace(/[\n]/ig,'&amps;').replace(/\s+/g,'&nbsp;') + "\"";
        }

        if(testcases != ""){
            jsonStr += ",\"stream\":[" + testcases.substring(0, testcases.length - 1) + "]";
        }
        jsonStr += "}";

        textfiled.value=jsonStr;
    }else{
        alert('Please at least choose a Power or Performance test case');
    }
}

function ppat_addBr(before){
    var br = document.createElement("br");
    before.insertBefore(br, null);
}

function ppat_addhr(before){
       var hr = document.createElement("hr");
       before.insertBefore(hr, null);
}

function ppat_addCheckbox(before, name, v, component){
        var power = document.createElement("input");
        power.id=v;
        power.type="checkbox";
        power.value=component;
        power.name=name;
        power.setAttribute("class", v);
        power.setAttribute("href", "#"+ v);
        before.insertBefore(power, null);
        before.insertBefore(document.createTextNode(v), null);
}

function ppat_addDeviceCase(device, submit){
        var testcases = device.split(",");
        var submit = document.getElementById("power_device");
        $("#power_device").html("");
        for(i = 0; i < testcases.length; i++){
                //ppat_addCheckbox(submit, "device", testcases[i], testcases[i]);
                var power = document.createElement("input");
                power.type="checkbox";
                power.value=deviceComponent[i];
                power.name="power";
                submit.insertBefore(power, null);
                submit.insertBefore(document.createTextNode(testcases[i]), null);
        }
}

function ppat_CheckboxSelectAll(name) {

    var checkbox = document.getElementsByTagName("input");
        for( var i = 0; i < checkbox.length; i++){
            if(checkbox[i].type == "checkbox" && checkbox[i].name == name){
                checkbox[i].checked = true;
            }
        }
  }

function ppat_CheckboxSelectComponent(name, component) {
    var checkbox = document.getElementsByTagName("input");
        for( var i = 0; i < checkbox.length; i++){
            if(checkbox[i].type == "checkbox" && checkbox[i].name == name && checkbox[i].value == component){
                checkbox[i].checked = true;
            }
        }
  }

function ppat_CheckboxSelectClear(name) {
    var checkbox = document.getElementsByTagName("input");
        for( var i = 0; i < checkbox.length; i++){
            if(checkbox[i].type == "checkbox" && checkbox[i].name == name){
                checkbox[i].checked = false;
            }
        }
   }

Array.prototype.del = function() {
    var a = {}, c = [], l = this.length;
    for (var i = 0; i < l; i++) {
        var b = this[i];
        var d = (typeof b) + b;
        if (a[d] === undefined) {
            c.push(b);
            a[d] = 1;
        }
    }
    return c;
}

function ppat_triggerValidate(thisform)
{
    with (thisform)
    {
        if (selected.value == "ppat_test_pxa988")
        {
            //load append ppat.xml to Text after validate
            ppat_appendToText("property3value");
//            if (ppat_validateRequired(property4value, "please input the Reason for Build") == false)
//            {
//                property4value.focus();
//                return false;
//            }
            if (ppat_validateRequired(property1value, "please input the Image Path") == false)
            {
                property1value.focus();
                return false;
            }
            if (ppat_validateRequired(property6value, "please select the device") == false)
            {
                property6value.focus();
                return false;
            }
            if (ppat_validateRequired(property7value, "please select the blf") == false)
            {
                property7value.focus();
                return false;
            }
            if (ppat_validateRequired(property3value, "please select power or performance test cases") == false)
            {
                property3value.focus();
                return false;
            }
        }
        if (selected.value == "ppat_test_eden")
        {
            //load append ppat.xml to Text after validate
            ppat_appendToText("property3value");
//            if (ppat_validateRequired(property4value, "please input the Reason for Build") == false)
//            {
//                property4value.focus();
//                return false;
//            }
            if (ppat_validateRequired(property1value, "please input the Image Path") == false)
            {
                property1value.focus();
                return false;
            }
            if (ppat_validateRequired(property6value, "please select the device") == false)
            {
                property6value.focus();
                return false;
            }
            if (ppat_validateRequired(property7value, "please select the blf") == false)
            {
                property7value.focus();
                return false;
            }
            if (ppat_validateRequired(property3value, "please select power or performance test cases") == false)
            {
                property3value.focus();
                return false;
            }
        }
        if (selected.value == "on_demand_virtual_build_with_ppat")
        {
            //load append ppat.xml to Text after validate
            ppat_appendToText("property2value");
//            if (ppat_validateRequired(property4value, "please input the Reason for Build") == false)
//            {
//                property4value.focus();
//                return false;
//            }
            if (ppat_validateRequired(property6value, "please input the manifest") == false)
            {
                property6value.focus();
                return false;
            }
            if (ppat_validateRequired(property8value, "please select the device") == false)
            {
                property8value.focus();
                return false;
            }
            if (ppat_validateRequired(property9value, "please select the blf") == false)
            {
                property9value.focus();
                return false;
            }
            if (ppat_validateRequired(property2value, "please select power or performance test cases") == false)
            {
                property2value.focus();
                return false;
            }
        }

    }
}

function ppat_validateRequired(field, alerttxt)
{
    with (field)
    {
        if (value==null||value=="")
        {
            alert(alerttxt);
            focus();
            return false;
         }
         for (i = 0; i < value.length; i++)
         {
             c = value.substr(i, 1);
             ts = escape(c);
             if(ts.substring(0,2) == "%u")
             {
                 alert("Chinese characters is not allowed!");
                 value = "";
                 return false;
             }
         }
    }
}

function branchSelect2(){
        var c = {
                "pxa1088dkb_def:pxa1088dkb":['HELN_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_WB_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_WB_Nontrusted_eMMC_512MB_400MHZ.blf', 'HELN_Nontrusted_eMMC_512MB_400MHZ.blf', 'HELN_WB_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_Nontrusted_eMMC_discrete.blf', 'HELN_WB_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_WT_Nontrusted_eMMC_512MB_400MHZ.blf'],
                "pxa1L88dkb_def:pxa1L88dkb":['HELN_LTE_Nontrusted_eMMC_400MHZ_1GB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_400MHZ_1GB.blf','HELN_LTE_Nontrusted_eMMC_400MHZ_512MB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_400MHZ_512M.blf','HELN_LTE_Nontrusted_eMMC_533MHZ_1GB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_533MHZ_1GB.blf','HELN_LTE_Nontrusted_eMMC_533MHZ_512MB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_533MHZ_512M.blf'],
                "concord_def:concord":['EDEN_Nontrusted_eMMC.blf']
                };

        var sel = document.getElementById("property6value");
        var op = sel.options[sel.selectedIndex];
        var r_devices = c[op.text];
        var r_device = document.getElementById("property7value");
        r_device.length=0;
        for(var i=0;i<r_devices.length;i++){
        var ops = new Option();
        ops.text = r_devices[i] ;
        r_device.options[i] = ops;
        }

        var submit = document.getElementById("DeviceHW");
        submit.style.display = "none";
        $("#device_module").remove();
        var div = document.createElement("div");
        div.id="device_module";
        submit.insertBefore(div, null);
        for(var i = 0; i < boardDevice.length; i++){
            if(boardDevice[i].type == op.text){
                var hwModule = new Array();
                hwModule = boardDevice[i].hw.split(";");
                for(var k = 0; k < hwModule.length; k++){
                    for(var j = 0; j < powerDevice.length; j++){
                        if(powerDevice[j].name == hwModule[k]){
                            submit.style.display = "block";
                            var radio = document.createElement("input");
                            radio.id = powerDevice[j].name;
                            radio.type = "radio";
                            radio.name = "device";
                            radio.onclick=(function(n){return function(){ ppat_addDeviceCase(powerDevice[n].TestCase, div);}})(j);
                            radio.value = powerDevice[j].name;
                            var textnode = document.createTextNode(powerDevice[j].name);
                            div.insertBefore(radio, null);
                            div.insertBefore(document.createTextNode(powerDevice[j].name), null);
                        }
                     }
                 }
            }
        }
        var advanced_tc = document.getElementById("power_adv");
        advanced_tc.style.display="none";
        $(xmlDoc).find("PowerAdvanced").each(function(i, ele){
            $(this).children("Platform").each(function(i){
                if($(this).text() == op.text){
                    advanced_tc.style.display="block";
                }
            });
        });
}

function branchSelect3(){
        var c = {
                "pxa1088dkb_def:pxa1088dkb":['HELN_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_WB_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_WB_Nontrusted_eMMC_512MB_400MHZ.blf', 'HELN_Nontrusted_eMMC_512MB_400MHZ.blf', 'HELN_WB_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_Nontrusted_eMMC_discrete.blf', 'HELN_WB_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_WT_Nontrusted_eMMC_512MB_400MHZ.blf'],
                "pxa1L88dkb_def:pxa1L88dkb":['HELN_LTE_Nontrusted_eMMC_400MHZ_1GB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_400MHZ_1GB.blf','HELN_LTE_Nontrusted_eMMC_400MHZ_512MB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_400MHZ_512M.blf','HELN_LTE_Nontrusted_eMMC_533MHZ_1GB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_533MHZ_1GB.blf','HELN_LTE_Nontrusted_eMMC_533MHZ_512MB.blf','HELN_LTE_TABLET_Nontrusted_eMMC_533MHZ_512M.blf']
                };

        var sel = document.getElementById("property8value");
        var op = sel.options[sel.selectedIndex];
        var r_devices = c[op.text];
        var r_device = document.getElementById("property9value");
        r_device.length=0;
        for(var i=0;i<r_devices.length;i++){
        var ops = new Option();
        ops.text = r_devices[i] ;
        r_device.options[i] = ops;
        }

        var submit = document.getElementById("DeviceHW");
        submit.style.display = "none";
        $("#device_module").remove();
        var div = document.createElement("div");
        div.id="device_module";
        submit.insertBefore(div, null);
        for(var i = 0; i < boardDevice.length; i++){
            if(boardDevice[i].type == op.text){
                var hwModule = new Array();
                hwModule = boardDevice[i].hw.split(";");
                for(var k = 0; k < hwModule.length; k++){
                    for(var j = 0; j < powerDevice.length; j++){
                        if(powerDevice[j].name == hwModule[k]){
                            submit.style.display = "block";
                            var radio = document.createElement("input");
                            radio.id = powerDevice[j].name;
                            radio.type = "radio";
                            radio.name = "device";
                            radio.onclick=(function(n){return function(){ ppat_addDeviceCase(powerDevice[n].TestCase, div);}})(j);
                            radio.value = powerDevice[j].name;
                            var textnode = document.createTextNode(powerDevice[j].name);
                            div.insertBefore(radio, null);
                            div.insertBefore(document.createTextNode(powerDevice[j].name), null);
                        }
                     }
                 }
            }
        }
        var advanced_tc = document.getElementById("power_adv");
        advanced_tc.style.display="none";
        $(xmlDoc).find("PowerAdvanced").each(function(i, ele){
            $(this).children("Platform").each(function(i){
                if($(this).text() == op.text){
                    advanced_tc.style.display="block";
                }
            });
        });
}
