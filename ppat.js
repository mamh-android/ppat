var xmlDoc;
var powerCase;
var powerComponent;
var performanceCase;
var powerDevice;
var deviceComponent;
var boardDevice;
var testcases="";
var countOfCmds=1;
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

function showAPM(id,target){
 if($("#"+id).attr("checked")){
    $("#"+target).css("display", "block");
    }else{
    $("#"+target).css("display", "none");
    }
}

function addCmd(){
    countOfCmds +=1;
    $("#add").before("</br><b>Please input another set of commands before run test cases:</b>");
    $("#add").before("</br>Description of set of cmds:<input id=" + countOfCmds + "r type=\"text\" name=\"reason\"></input></br><textarea id=" + countOfCmds + " cols=\"60\" rows=\"10\"></textarea></br>");

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

    $(xmlDoc).find("PowerAdvanced").each(function(i, ele){
        $(this).children("Platform").each(function(i){
            if($("#" + $(this).text().substring(0, 7)).length > 0){
                var text = "<input type=\"checkbox\" id=\"" + $(ele).children("CaseName").text() + "\" value=\"" + $(this).text() +"\" name=\"poweradv\" class=\"" + $(ele).children("CaseName").text() + "\" href=\"#" + $(ele).children("CaseName").text() + "\">" + $(ele).children("CaseName").text();
                $("#" + $(this).text().substring(0, 7)).append(text);
            }else{
                var platform = document.createElement("div");
                platform.id=$(this).text().substring(0, 7);
                submit.insertBefore(platform, null);
                var text = "<input type=\"checkbox\" id=\"" + $(ele).children("CaseName").text() + "\" value=\"" + $(this).text() +"\" name=\"poweradv\" class=\"" + $(ele).children("CaseName").text() + "\" href=\"#" + $(ele).children("CaseName").text() + "\">" + $(ele).children("CaseName").text();
                $("#" + $(this).text().substring(0, 7)).append(text);
                $("#" + $(this).text().substring(0, 7)).css("display", "none");
                }
            //ppat_addCheckbox(advanced_tc,"poweradv", $(ele).children("CaseName").text(), $(this).text());
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
        ppat_addBr(submit);

//add APM tool here
        label = document.createElement("label");
        label.id="apm";
        submit.insertBefore(label, null);   
        ppat_addBr(submit);
        
        var apm = document.createElement("div");
        apm.id="apmdiv";
        apm.style.display = "none";
        submit.insertBefore(apm, null);
        $("#apm").append("<input id=\"apmEn\" type=\"checkbox\" name=\"apm\" onclick=\"showAPM(\'apmEn\',\'" + apm.id+"\')\" value=\"apm\"/><b>APM for uboot power test:</b>");

// lpm En
        label = document.createElement("label");
        label.id="lpm";
        apm.insertBefore(label, null);  

        var lpm = document.createElement("div");
        lpm.id="lpmdiv";
        lpm.style.display = "none";
        apm.insertBefore(lpm, null);

        $("#lpm").append("<input id=\"lpmEn\" type=\"checkbox\" name=\"lpm\" onclick=\"showAPM(\'lpmEn\',\'" + lpm.id +"\')\" value=\"lpm\"/><b>Enable LPM Test</b>");
        
// core
    label = document.createElement("label");
        label.id="core";
        label.name="core";
        label.innerHTML="*available core freq:";
        lpm.insertBefore(label, null);  
    $("#core").after("<input id=\"corefreq\" style=\"width:200px\" type=\"text\" name=\"corefreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"156,312,624,800,1183\"</b></span></br>");
//ddr
    label = document.createElement("label");
        label.id="ddr";
        label.name="ddr";
        label.innerHTML="*available ddr freq:";
        lpm.insertBefore(label, null);  
    $("#ddr").after("<input id=\"ddrfreq\" style=\"width:200px\" type=\"text\" name=\"ddrfreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"156,312,533\"</b></span></br>");
    
//axi
    label = document.createElement("label");
        label.id="axi";
        label.name="axi";
        label.innerHTML="*available axi freq:";
        lpm.insertBefore(label, null);  
    $("#axi").append("<input id=\"axifreq\" style=\"width:200px\" type=\"text\" name=\"axi\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"78,156,533\"</b></span></br>");

//lpm
        label = document.createElement("label");
        label.id="lpmvallb";
        label.name="lpm";
        lpm.insertBefore(label, null);  
        
        $("#lpmvallb").after("*available lpm value:<input id=\"lpmval\" type=\"text\" name=\"lpmval\" /><span style=\" font-size:12px;color:#999999\">available lpm, like <b>\"c22,d1,d2,udr\"</b></span><br/>");

// lcd En
        label = document.createElement("label");
        label.id="lcd";
        apm.insertBefore(label, null);  

        var lcd = document.createElement("div");
        lcd.id="lcddiv";
        lcd.style.display = "none";
        apm.insertBefore(lcd, null);

        $("#lcd").append("<input id=\"lcdEn\" type=\"checkbox\" name=\"lcd\" onclick=\"showAPM(\'lcdEn\',\'" + lcd.id +"\')\" value=\"lcd\"/><b>Enable LCD Test</b>");
// lcd freq
    label = document.createElement("label");
        label.id="lcdl";
        label.name="lcd";
        label.innerHTML="*available lcd freq:";
        lcd.insertBefore(label, null);  
    $("#lcdl").after("<input id=\"lcdfreq\" style=\"width:200px\" type=\"text\" name=\"lcdfreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"208,312,416\"</b></span></br>");

// isp En
        label = document.createElement("label");
        label.id="isp";
        apm.insertBefore(label, null);  
        var isp = document.createElement("div");
        isp.id="ispdiv";
        isp.style.display = "none";
        apm.insertBefore(isp, null);

        $("#isp").append("<input id=\"ispEn\" type=\"checkbox\" name=\"isp\" onclick=\"showAPM(\'ispEn\',\'" + isp.id +"\')\" value=\"isp\"/><b>Enable ISP Test</b>");
// isp freq
    label = document.createElement("label");
        label.id="ispl";
        label.name="isp";
        label.innerHTML="*available isp freq:";
        isp.insertBefore(label, null);  
    $("#ispl").after("<input id=\"ispfreq\" style=\"width:200px\" type=\"text\" name=\"ispfreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"208,312,416\"</b></span></br>");

// vpu En
        label = document.createElement("label");
        label.id="vpu";
        apm.insertBefore(label, null);  
        var vpu = document.createElement("div");
        vpu.id="vpudiv";
        vpu.style.display = "none";
        apm.insertBefore(vpu, null);
        $("#vpu").append("<input id=\"vpuEn\" type=\"checkbox\" name=\"vpu\" onclick=\"showAPM(\'vpuEn\',\'" + vpu.id +"\')\" value=\"vpu\"/><b>Enable VPU Test</b>");
// vpu freq
    label = document.createElement("label");
        label.id="vpul";
        label.name="vpu";
        label.innerHTML="*available vpu freq:";
        vpu.insertBefore(label, null);  
    $("#vpul").after("<input id=\"vpufreq\" style=\"width:200px\" type=\"text\" name=\"vpufreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"208,312,416\"</b></span></br>");

// gc2d En
        label = document.createElement("label");
        label.id="gc2d";
        apm.insertBefore(label, null);  
        var gc2d = document.createElement("div");
        gc2d.id="gc2ddiv";
        gc2d.style.display = "none";
        apm.insertBefore(gc2d, null);
        $("#gc2d").append("<input id=\"gc2dEn\" type=\"checkbox\" name=\"gc2d\" onclick=\"showAPM(\'gc2dEn\',\'" + gc2d.id +"\')\" value=\"gc2d\"/><b>Enable gc2d Test</b>");
// gc2d freq
    label = document.createElement("label");
        label.id="gc2dl";
        label.name="gc2d";
        label.innerHTML="*available gc2d freq:";
        gc2d.insertBefore(label, null); 
    $("#gc2dl").after("<input id=\"gc2dfreq\" style=\"width:200px\" type=\"text\" name=\"gc2dfreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"208,312,416,624\"</b></span></br>");

// gc3d En
        label = document.createElement("label");
        label.id="gc3d";
        apm.insertBefore(label, null);  
        var gc3d = document.createElement("div");
        gc3d.id="gc3ddiv";
        gc3d.style.display = "none";
        apm.insertBefore(gc3d, null);
        $("#gc3d").append("<input id=\"gc3dEn\" type=\"checkbox\" name=\"gc3d\" onclick=\"showAPM(\'gc3dEn\',\'" + gc3d.id +"\')\" value=\"gc3d\"/><b>Enable gc3d Test</b>");
// gc2d freq
    label = document.createElement("label");
        label.id="gc3dl";
        label.name="gc3d";
        label.innerHTML="*available gc3d freq:";
        gc3d.insertBefore(label, null); 
    $("#gc3dl").after("<input id=\"gc3dfreq\" style=\"width:200px\" type=\"text\" name=\"gc3dfreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"208,312,416,624\"</b></span></br>");

// gcsh En
        label = document.createElement("label");
        label.id="gcsh";
        apm.insertBefore(label, null);  
        var gcsh = document.createElement("div");
        gcsh.id="gcshdiv";
        gcsh.style.display = "none";
        apm.insertBefore(gcsh, null);
        $("#gcsh").append("<input id=\"gcshEn\" type=\"checkbox\" name=\"gcsh\" onclick=\"showAPM(\'gcshEn\',\'" + gcsh.id +"\')\" value=\"gcsh\"/><b>Enable gc shader Test</b>");
// gcsh freq
    label = document.createElement("label");
        label.id="gcshl";
        label.name="gcsh";
        label.innerHTML="*available gc shader freq:";
        gcsh.insertBefore(label, null); 
    $("#gcshl").after("<input id=\"gcshfreq\" style=\"width:200px\" type=\"text\" name=\"gcshfreq\" /><span style=\" font-size:12px;color:#999999\">freq like <b> \"208,312,416,624\"</b></span>");

//voltage
        label = document.createElement("label");
        label.id="volvalues";
        label.name="vol";
        apm.insertBefore(label, null);  

        $("#volvalues").after("<br/>*min voltage:<input id=\"volmin\" style=\"width:50px\" type=\"text\" name=\"volmin\" />mV&nbsp;&nbsp;&nbsp;&nbsp;"
        + "*max voltage:<input id=\"volmax\" style=\"width:50px\" type=\"text\" name=\"volmax\" />mV&nbsp;&nbsp;&nbsp;&nbsp;"
        + "*step: <input id=\"volstep\" style=\"width:50px\" type=\"text\" name=\"volstep\" />mV&nbsp;&nbsp;&nbsp;&nbsp;"
        + "order:<input id=\"volorder\" style=\"width:20px\" type=\"text\" name=\"volorder\" /><span style=\" font-size:12px;color:#999999\">1: mean asceding, 0: men descending. Default is 0</span></br>"
        +"test loop:<input id=\"loop\" style=\"width:20px\" type=\"text\" name=\"loop\" /><span style=\" font-size:12px;color:#999999\">test loop, default is<b>\"2\"</b></span><br/>");
        
        
    ppat_addhr(submit);
    label = document.createElement("label");
    label.id="power_textarea";
    label.name="power";
    label.innerHTML="<b>Please input some special commands before run test cases:</b>";

    submit.insertBefore(label, null);
$("#power_textarea").after("</br>Test loop:<input id=\"loopPPAT\" style=\"width:20px\" type=\"text\" name=\"loopPPAT\" /><span style=\" font-size:12px;color:#999999\">test loop, default is<b>\"3\"</b></span>");
        $("#power_textarea").after("</br><input id=\"add\" type=\"button\" name=\"Button_ClearAll\" onclick=\"addCmd()\" value=\"Add another set of cmds for PPAT test\"></input>");
        $("#power_textarea").after("</br>Description of set of cmds:<input id=" + countOfCmds + "r type=\"text\" name=\"reason\"></input></br><textarea id=" + countOfCmds + " cols=\"60\" rows=\"10\"></textarea>");

    

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

function ppat_releaseCheckbox(){
    var chks = document.getElementsByTagName("input");
     for (var i = 0; i < chks.length; i++) {
        if (chks[i].type == "checkbox" ) {
            chks[i].checked = false;
         }
    }
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
        if($("#apmEn").attr("checked")){
            caseCount += 1;
            jsonStr += "{\"Name\":\"apm_ppat\"},";
        }
    if(caseCount >= 1){
        jsonStr = "{\"TestCaseList\":[" + jsonStr.substring(0, jsonStr.length - 1) + "]";
                for(var c = 1; c <= countOfCmds; c++){
                        
                        if($("#"+c).val() != ""){
                        jsonStr +=",\"inputs\":[";
                        break;
                    }
                }
        $('textarea').each(function(){                      
                         var text = $(this).val();//commands
                         if(text != ""){
                                
                                var description = $("#" + ($(this).attr("id")+ "r")).attr("value");//reason
                                if(description == ""){
                                    description = "null";
                                }
                                jsonStr += "{\"description\":\"" + description + "\",";
                                jsonStr += "\"commands\":\"" + text + "\"},";
                         }
                });
                jsonStr = jsonStr.substring(0, jsonStr.length - 1) + "]";
                //loop
                var lp = $("#loopPPAT").val();
                if(lp != ""){
                    jsonStr +=",\"count\":\"" + $("#loopPPAT").val() + "\"";
                }
        if(testcases != ""){
            jsonStr += ",\"stream\":[" + testcases.substring(0, testcases.length - 1) + "]";
        }

                if($("#apmEn").attr("checked")){
                        if($("#lpmEn").attr("checked")){
                                jsonStr +=",\"lpm_en\":\"1\"";
                            var corefreq = $("#corefreq").attr("value");
                            var ddrfreq = $("#ddrfreq").attr("value");
                            var axifreq = $("#axifreq").attr("value");
                            var lpmval = $("#lpmval").attr("value");
                            if(corefreq == "" || ddrfreq == "" || axifreq == "" || lpmval == ""){
                                if(corefreq =="") alert("Please input core freq");
                                if(ddrfreq =="") alert("Please input ddr freq");
                                if(axifreq =="") alert("Please input axi freq");
                                if(lpmval =="") alert("Please input lpm values");
                            }else{
                                jsonStr +=",\"corefreq\":\""+ corefreq +"\"";
                                jsonStr +=",\"ddrfreq\":\""+ ddrfreq +"\"";
                                jsonStr +=",\"axifreq\":\""+ axifreq +"\"";
                                jsonStr +=",\"lpmval\":\""+ lpmval +"\"";
                            }
                        }
                        if($("#lcdEn").attr("checked")){
                                jsonStr +=",\"lcd_en\":\"1\"";
                                var lcdfreq = $("#lcdfreq").attr("value");
                                if(lcdfreq == ""){
                                     alert("Please input lcd freq");
                                }else{
                                    jsonStr +=",\"lcdfreq\":\""+ lcdfreq +"\"";
                                }
                        }
                        if($("#ispEn").attr("checked")){
                                jsonStr +=",\"isp_en\":\"1\"";
                                var ispfreq = $("#ispfreq").attr("value");
                                if(ispfreq == ""){
                                     alert("Please input isp freq");
                                }else{
                                    jsonStr +=",\"ispfreq\":\""+ ispfreq +"\"";
                                }
                        }
                        if($("#vpuEn").attr("checked")){
                                jsonStr +=",\"vpu_en\":\"1\"";
                                var vpufreq = $("#vpufreq").attr("value");
                                if(vpufreq == ""){
                                     alert("Please input vpu freq");
                                }else{
                                    jsonStr +=",\"vpufreq\":\""+ vpufreq +"\"";
                                }
                        }
                        if($("#gc2dEn").attr("checked")){
                                jsonStr +=",\"gc2d_en\":\"1\"";
                                var gc2dfreq = $("#gc2dfreq").attr("value");
                                if(gc2dfreq == ""){
                                     alert("Please input gc2d freq");
                                }else{
                                    jsonStr +=",\"gc2dfreq\":\""+ gc2dfreq +"\"";
                                }
                        }
                        if($("#gc3dEn").attr("checked")){
                                jsonStr +=",\"gc3d_en\":\"1\"";
                                var gc3dfreq = $("#gc3dfreq").attr("value");
                                if(gc3dfreq == ""){
                                     alert("Please input gc3d freq");
                                }else{
                                    jsonStr +=",\"gc3dfreq\":\""+ gc3dfreq +"\"";
                                }
                        }
                        if($("#gcshEn").attr("checked")){
                                jsonStr +=",\"gcshader_en\":\"1\"";
                                var gcshfreq = $("#gcshfreq").attr("value");
                                if(gcshfreq == ""){
                                     alert("Please input gcsh freq");
                                }else{
                                    jsonStr +=",\"gcshfreq\":\""+ gcshfreq +"\"";
                                }
                        }
                        var volmin = $("#volmin").attr("value");
                        var volmax = $("#volmax").attr("value");
                        var volstep = $("#volstep").attr("value");
                        var volorder = $("#volorder").attr("value");
                        var loop = $("#loop").attr("value");
                        if(volmin == "" || volmax == "" || volstep==""){
                            if(volmin =="") alert("Please input min volgate");
                            if(volmax =="") alert("Please input max volgate");
                            if(volstep =="") alert("Please input voltage change step");
                        }else{
                            jsonStr +=",\"volmin\":\"" + volmin + "\"";
                            jsonStr +=",\"volmax\":\"" + volmax + "\"";
                            jsonStr +=",\"volstep\":\"" + volstep + "\"";
                            if(volorder != ""){
                                jsonStr +=",\"volorder\":\"" + volorder + "\"";
                            }
                            if(loop != ""){
                                jsonStr +=",\"loop\":\"" + loop + "\"";
                            }
                        }
                }
        jsonStr += "}";
        jsonStr = jsonStr.replace(/[\n]/ig,'&amps;').replace(/\s+/g,'&nbsp;');

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
                "pxa1L88dkb_def:pxa1L88dkb":['HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_1GB.blf'],
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
        ppat_releaseCheckbox();
        $(xmlDoc).find("PowerAdvanced").each(function(i, ele){
            $(this).children("Platform").each(function(i){
                $("#" + $(this).text().substring(0, 7)).css("display", "none");
                if($(this).text() == op.text){
                    advanced_tc.style.display="block";
                    $("#" + $(this).text().substring(0, 7)).css("display", "block");
                }
            });
        });
}

function branchSelect3(){
        var c = {
                "pxa1088dkb_def:pxa1088dkb":['HELN_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_WB_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_WB_Nontrusted_eMMC_512MB_400MHZ.blf', 'HELN_Nontrusted_eMMC_512MB_400MHZ.blf', 'HELN_WB_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_Nontrusted_eMMC_512MB_533MHZ.blf', 'HELN_WT_Nontrusted_eMMC_1GB_533MHZ.blf', 'HELN_Nontrusted_eMMC_discrete.blf', 'HELN_WB_Nontrusted_eMMC_1GB_400MHZ.blf', 'HELN_WT_Nontrusted_eMMC_512MB_400MHZ.blf'],
                "pxa1L88dkb_def:pxa1L88dkb":['HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_1GB.blf'],
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
        ppat_releaseCheckbox();
        $(xmlDoc).find("PowerAdvanced").each(function(i, ele){
            $(this).children("Platform").each(function(i){
                $("#" + $(this).text().substring(0, 7)).css("display", "none");
                if($(this).text() == op.text){
                    advanced_tc.style.display="block";
                    $("#" + $(this).text().substring(0, 7)).css("display", "block");
                }
            });
        });
}
