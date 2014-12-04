var xmlDoc;
var powerCase;
var powerCategory;
var performanceCategory;
var performanceCase;
var powerDevice;
var deviceCategory;
var powerAdvancedCase;
var	platform;
var boardDevice;
var powerAdvCategory;
var device;
var testType="PowerScenario";
var countOfCmds=1;
var property = new Array();
var blfArr = new Array();
function ppat_load(buildtype){
    var strURL = "http://10.38.32.97:3000/scenarios";
            $.ajax({
              type: "GET",
              url: strURL,
              timeout:3000,
              dataType:'html',
              success: function(msg){
                    powerCase = new Array();
                    powerCategory = new Array();
                    performanceCategory = new Array();
                    performanceCase = new Array();
                    powerDevice = new Array();
                    deviceCategory = new Array();
                    boardDevice = new Array();
					platform = new Array();
					powerAdvancedCase = new Array();
					powerAdvCategory = new Array();		
                    domParser = new DOMParser();
                    xmlDoc = domParser.parseFromString(msg, 'text/xml');
                    ppat_parsePowerNode();
					ppat_parseAdvancedPowerNode();
                    ppat_parsePerformanceNode();
                    ppat_parseDeviceNode();
                    ppat_parseBoardDevice();
                    generateUI(buildtype);
                    ppat_load_testcase();
                    ppat_load_blf();
              }
            });
}

function ppat_update_checkbox(id,stream, duration){
    $("."+id).attr("checked",true);
		var str = "";
    str += "\"Stream\":\"" + stream + "\",";
    str += "\"Duration\":\"" + duration + "\"";	
	property[id] = str;
}

function showAPM(id,target){
	if($("#"+id).attr("checked")){
		$("#"+target).css("display", "block");
    }else{
		$("#"+target).css("display", "none");
    }
}

function addCmd(){
	$("#add").before("<div id=\"div_" + countOfCmds + "\"></div>");
	$("#div_" + countOfCmds).append("<b>Input commands before run test cases:</b></br>");
    $("#div_" + countOfCmds).append("Description of set of cmds:<input id=" + countOfCmds + "r type=\"text\" name=\"reason\"></input> </br><textarea id=" + countOfCmds + " cols=\"60\" rows=\"10\"></textarea><img src=\"ppat/delete.png\" onclick=\"demiss(div_" + countOfCmds + ")\"></img></br>");
    countOfCmds +=1;
}
function demiss(id){
	$(id).remove();
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
	$(xmlDoc).find("Board").each(function(){
		var str = "{";
		str += "\"type\":\"" + $(this).find("Type").text() + "\",";
		var modules = new Array();
		$(this).find("Name").each(function(){
			modules.push($(this).text());
		});
		str += "\"hw\":\"" + modules.join(";") + "\"";
        str += "}";
        boardDevice.push(eval('(' + str + ')'));
	});
}

function ppat_parseDeviceNode(){
	$(xmlDoc).find("Device").each(function(){
		var str = "{";
		str += "\"name\":\"" + $(this).find("Name").text() + "\",";
		var cases = new Array();
		$(this).find("CaseName").each(function(){
			//powerCategory.push($(this).attr("Component"));
			deviceCategory.push($(this).attr("Category"));
			cases.push($(this).text());
		});
		str += "\"TestCase\":\"" + cases + "\"";
        str += "}";
        powerDevice.push(eval('(' + str + ')'));
	});
}

function ppat_parsePowerNode(){
	$(xmlDoc).find("Power").each(function(){
		powerCase.push($(this).find("CaseName").text());
		powerCategory.push($(this).find("Category").text());
	});
}

function ppat_parseAdvancedPowerNode(){
	$(xmlDoc).find("PowerAdvanced").each(function(){
		powerAdvancedCase.push($(this).find("CaseName").text());
		platform.push($(this).find("Platform").text());
		powerAdvCategory.push($(this).find("Category").text());
	});
}

function ppat_parsePerformanceNode(){
	$(xmlDoc).find("Performance").each(function(){
		performanceCase.push($(this).find("CaseName").text());
		performanceCategory.push($(this).find("Category").text());
	});
}

function chooseTest(select){
	testType = $(select).val();
	$("#selection").empty();
	$("#selection").append("<hr><b>" + $(select).val() + " Test</b><hr>");
	updateTable(testType);
}

function updateTable(testType){
	if(testType == "PowerScenario"){
		addScenarioCheckbox();
		addUIScenarioCheckbox();
		$("#tune").empty();
		$("#baremetal").empty();
		$("#DeviceHW").css("display", "block");
	}else if(testType == "Round PP Tuning"){
		addScenarioCheckbox();
		addUIScenarioCheckbox();
		$("#baremetal").empty();
		//add tune parameters here
		$("#DeviceHW").css("display", "block");
		ppat_load_tune();
	}else{
		$("#tune").empty();
		$("#scenario").empty();
		$("#advscenario").empty();
		$("#ui").empty();
		$("#DeviceHW").css("display", "none");
		ppat_load_baremetal();
	}

}

function ppat_load_baremetal(){
	var ubootURL = "http://10.38.32.97:3000/tc/uboot";
	var baremetaldiv = $("#baremetal");
	baremetaldiv.empty();
	$.ajax({
		type: "GET",
        url: ubootURL,
        timeout:3000,
        dataType:'html',
        success: function(data){
			var bare_xml = new DOMParser().parseFromString(data, 'text/xml');
			$(bare_xml).find("Device").each(function(){
				if($(this).attr("name") == device){
					//find component cpu/ddr/axi...
					$(this).find("Component").each(function(){
						var compName = $(this).attr("name");
						baremetaldiv.append("<br/><b>" + compName + "</b><hr>");
						baremetaldiv.append("<div id=\"" + compName + "\"><ul></ul></div>");
						//find testcase
						$(this).find("TestCase").each(function(){
							var caseName = $(this).find("CaseName").text();
							$("<li><a href=\"#" + caseName + "\">" + caseName + "</a><li>").appendTo("#" + compName + " ul");

							var divInfo = "<div id=\"" + caseName + "\"></div>";
							//add component vol/freq info
							var table="<table cellspacing=\"0px\" border=\"1\" width=\"100%\"><tr><th colspan=\"2\" align=\"left\" height=\"50px\">Select Parameters:</th></tr>";


							table += "<tr><td class=\"category\">Voltage:</td><td class=\"case\"><input type=\"text\" onkeyup=\"verify(this)\" onblur=\"veryfyBlur(this)\" name=\"" + compName + "vol\">mV  split with ','</td></tr>";
							$(this).children().each(function(){
								var nodeName = $(this).context.nodeName; // name of cpu/ddr
								if(nodeName != "CaseName"){
									$(this).children().each(function(){
										table += "<tr><td class=\"category\">"+ nodeName + " " + $(this).context.nodeName + "</td>";
										table += "<td class=\"case\">";
										var params = $(this).text().split(",");
										for(var i = 0; i < params.length; i++){
											var type = $(this).attr("type");
											if(type == "checkbox"){
												if($(this).attr("checked")){
													table +="<div><input type=\"checkbox\" checked=\"" + $(this).attr("checked") + "\" text=\"" + params[i] + "\" param=\"" + nodeName + $(this).context.nodeName + "\">" + params[i] + "</div>";
												}else{
													table +="<div><input type=\"checkbox\" text=\"" + params[i] + "\" param=\"" + nodeName + "_" + $(this).context.nodeName + "\">" + params[i] + "</div>";
												}
											}else if(type == "radio"){
												if($(this).attr("checked")){
													table +="<div><input type=\"radio\" checked=\"" + $(this).attr("checked") + "\" text=\"" + params[i] + "\" name=\"" + caseName + "_" + nodeName + "_" + $(this).context.nodeName + "\" param=\"" + nodeName + "_" + $(this).context.nodeName + "\">" + params[i] + "</div>";
												}else{
													table +="<div><input type=\"radio\" text=\"" + params[i] + "\" name=\"" + caseName + "_" + nodeName + "_" + $(this).context.nodeName + "\" param=\"" + nodeName + "_" + $(this).context.nodeName + "\">" + params[i] + "</div>";
												}
											}
										}
                                        table += "</td></tr>";
									});
									if(nodeName == "cmd"){
										table += "<tr><td class=\"category\">" + nodeName + "</td>";
										table += "<td><input type=\"text\" name=\"cmd\" style=\"width:80%\" value=\"" + $(this).text().replace(/\"/g, '&quot;') + "\">";
										table += "</td></tr>";
									}
								}
							});
							$(divInfo).appendTo("#" + compName);
							$("#" + caseName).append(table);
						});
						$("#" + compName).tabs();
					});
				}
			});
			style();
		}
	});
}

function ppat_load_blf(){
    var blfURL = "http://10.38.32.97:3000/tc/blf";
    $.ajax({
        type: "GET",
        url: blfURL,
        timeout: 3000,
        dataType: 'html',
        success: function(data){
            var blf_xml = new DOMParser().parseFromString(data, 'text/xml');
            $(blf_xml).find("Device").each(function(){
                var blf = new Array();
                $(this).children().each(function(){
                    blf.push($(this).text());
                });
                blfArr[$(this).attr("name")] = blf;
            });
        }
    });
}

function ppat_load_tune(){
    var tuneURL = "http://10.38.32.97:3000/tc/tune";
	var tunediv = $("#tune");
	tunediv.empty();
    $.ajax({
        type: "GET",
        url: tuneURL,
        timeout:3000,
        dataType:'html',
        success: function(data){
             var tune_xml = new DOMParser().parseFromString(data, 'text/xml');
             $(tune_xml).find("Device").each(function(){
				if($(this).attr("name") == device){
					var table="<table cellspacing=\"0px\" border=\"1\" width=\"100%\"><tr><th colspan=\"2\"><div class=\"tabletitle\">Round PP Tuning</div></th></tr>";
					$(this).find("cpu").each(function(){
						table +="<tr><td style=\"text-align:left;\" colspan=\"2\" height=20>CPU:</td></tr>";
						$(this).children().each(function(){
							var nodeName = $(this).context.nodeName;
							if($(this).text() == null || $(this).text() == ""){
								table += "<tr><td class=\"category\">" + nodeName + ": </td>";
								table += "<td class=\"case cpu\" width=\"85%\"><input type=\"text\" name=\"cpu\" param=\"" + nodeName + "\"> split with ','";
								table += "</td></tr>";
							}else{
								table += "<tr><td class=\"category\"><input type=\"checkbox\" onclick=\"ppat_CheckboxSelectAll('tune', 'cpu_" + nodeName + "', 'cpu_" + nodeName + "')\" id=\"cpu_" + nodeName + "\">"+ nodeName + "</td>";
								table += "<td class=\"case cpu\">";
								var params = $(this).text().split(",");
		                 		for(var i = 0; i < params.length; i++){
									table += "<div><input type=\"checkbox\" id=\"cpu_" + params[i] + "\" father=\"cpu_" + nodeName + "\" onclick=\"ppat_CheckboxSelectAll('tune', 'cpu_" + params[i] + "', 'cpu_" + nodeName + "')\" name=\"" + params[i] + "\"" + " value=\"cpu_" + nodeName + "\" param=\"" + nodeName +"\">" + params[i] + "</div>";
								}
								table += "</td></tr>";
							}
						});
					});
					$(this).find("gpu").each(function(){
						var unit = $(this).attr("unit");
						table +="<tr><td style=\"text-align:left;\" colspan=\"2\" height=20>GPU" +unit + ":</td></tr>";
						$(this).children().each(function(){
							var nodeName = $(this).context.nodeName;
							if($(this).text() == null || $(this).text() == ""){
								table += "<tr><td class=\"category\">" + nodeName + ": </td>";
								table += "><td class=\"case gpu\"><input type=\"text\" name=\"gpu\" param=\"" + nodeName + "\"> split with ','";
								table += "</td></tr>";
							}else{
								table += "<tr><td class=\"category\"><input type=\"checkbox\" onclick=\"ppat_CheckboxSelectAll('tune', 'gpu_" + unit + nodeName + "' ,'gpu_" + unit + nodeName + "')\"  id=\"gpu_" + unit + nodeName + "\">"+ nodeName + "</td>";
								table += "<td class=\"case gpu" + unit + "\">";
								var params = $(this).text().split(",");
		                 		for(var i = 0; i < params.length; i++){
									table +="<div><input type=\"checkbox\" id=\"gpu_" + unit + params[i] + "\" father=\"gpu_" + unit + nodeName + "\" onclick=\"ppat_CheckboxSelectAll('tune', 'gpu_" + unit + params[i] + "', 'gpu_" + unit + nodeName + "')\" name=\"" + params[i] + "\"" + " value=\"gpu_" + unit + nodeName + "\" param=\"" + nodeName +"\">" + params[i] + "</div>";
								}
								table += "</td></tr>";
							}
						});
					});
					$(this).find("vpu").each(function(){
						var unit = $(this).attr("unit");
						table +="<tr><td style=\"text-align:left;\" colspan=\"2\" height=20>VPU" +unit + ":</td></tr>";
						$(this).children().each(function(){
							var nodeName = $(this).context.nodeName;
							if($(this).text() == null || $(this).text() == ""){
								table += "<tr><td class=\"category\">" + nodeName + ": </td>";
								table += "<td class=\"case vpu\"><input type=\"text\" name=\"vpu\" param=\"" + nodeName + "\"> split with ','";
								table += "</td></tr>";
							}else{
								table += "<tr><td class=\"category\"><input type=\"checkbox\" onclick=\"ppat_CheckboxSelectAll('tune', 'vpu_" + unit + nodeName + "' ,'vpu_" + unit + nodeName + "')\"  id=\"vpu_" + unit + nodeName + "\">"+ nodeName + "</td>";
								table += "<td class=\"case vpu" + unit + "\">";
								var params = $(this).text().split(",");
		                 		for(var i = 0; i < params.length; i++){
									table +="<div><input type=\"checkbox\" id=\"vpu_" + unit + params[i] + "\" father=\"vpu_" + unit + nodeName + "\" onclick=\"ppat_CheckboxSelectAll('tune', 'vpu_" + unit + params[i] + "', 'vpu_" + unit + nodeName + "')\" name=\"" + params[i] + "\"" + " value=\"vpu_" + unit + nodeName + "\" param=\"" + nodeName +"\">" + params[i] + "</div>";
								}
								table += "</td></tr>";
							}
						});
					});
					$(this).find("ddr").each(function(){
						table +="<tr><td style=\"text-align:left;\" colspan=\"2\" height=20>DDR:</td></tr>";
						$(this).children().each(function(){
							var nodeName = $(this).context.nodeName;
							if($(this).text() == null || $(this).text() == ""){
								table += "<tr><td class=\"category\">" + nodeName + ": </td>";
								table += "<td class=\"case ddr\"><input type=\"text\" name=\"ddr\" param=\"" + nodeName + "\"> split with ','";
								table += "</td></tr>";
							}else{
								table += "<tr><td class=\"category\"><input type=\"checkbox\" onclick=\"ppat_CheckboxSelectAll('tune', 'ddr_" + nodeName + "', 'ddr_" + nodeName + "')\" id=\"ddr_" + nodeName + "\">"+ nodeName + "</td>";
								table += "<td class=\"case ddr\">";
								var params = $(this).text().split(",");
		                 		for(var i = 0; i < params.length; i++){
									table += "<div><input type=\"checkbox\" id=\"ddr_" + params[i] + "\" father=\"ddr_" + nodeName + "\" onclick=\"ppat_CheckboxSelectAll('tune', 'ddr_" + params[i] + "', 'ddr_" + nodeName + "')\" name=\"" + params[i] + "\"" + " value=\"ddr_" + nodeName + "\" param=\"" + nodeName +"\">" + params[i] + "</div>";
								}
								table += "</td></tr>";
							}
						});
					});
				tunediv.append(table + "</table>");
				}
			});
			style();
		}
    });
}

function generateUI(buildtype){

    var submit;
    if(buildtype == "ppat_test"){
        $("#odvb_ppat").html("");
        $("#org_ppat").html("");
        submit = $("#org_ppat");
    }else {
        $("#org_ppat").html("");
        $("#odvb_ppat").html("");
        submit = $("#odvb_ppat");
    }
	submit.append("<label id=\"DeviceHW\" style=\"display: block; \"></label><br>");
    var colorbox = "<div style='display:none'>" +
                    "<div id='1080p' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                    "<div id='720p' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                    "<div id='VGA' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                    "<div id='mp3' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">audio</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" ;

	submit.append("<div id=\"powercase\" style=\"display: block; \">"
					+ "*Choose Test: <select onchange=\"chooseTest(this)\">"
					+ "<option>PowerScenario</option>"
					+ "<option>Round PP Tuning</option>"
					+ "<option>Baremetal Power</option>"
					+ "</select>"
					+ "<div id=\"selection\"><hr><b>PowerScenario Test</b><hr></div></div>");
	submit.append("<div id=\"scenario\" style=\"display: block; \"></div>");
	submit.append("<div id=\"advscenario\" style=\"display: block; \"></div>");
	submit.append("<div id=\"ui\" style=\"display: block; \"></div>");
	submit.append("<div id=\"baremetal\" style=\"display: block; \"></div>");
	addScenarioCheckbox();
	addUIScenarioCheckbox();
	submit.append(colorbox);
	submit.append("<div id=\"cmd\" style=\"display: block; \"></div>");
	submit.append("<div id=\"tune\" style=\"display: block; \">");
	submit.append("<hr><b>Please click \"Add cmds for PPAT test\" if you need input commmands<hr><input id=\"add\" type=\"button\" onclick=\"addCmd()\" value=\"Add cmds for PPAT test\">");

}

function addAdvancedScenarioCheckbox(pf){
	var adv_scenario_div = $("#advscenario");
	adv_scenario_div.html("");

	powerAdvCategory_b = powerAdvCategory.concat().del();
	platform_b = platform.concat();
	platform_b = platform_b.del();
	for(var i = 0; i < platform_b.length; i++){
		if(platform_b[i] == pf){
			var table="<table id=\"scenario_table\" cellspacing=\"0px\" border=\"1\" width=\"100%\"><tr><th colspan=\"2\"><div class=\"tabletitle\">CP Power</div><div><input type=\"checkbox\" value=\"Select All\"  onclick=\"ppat_CheckboxSelectAll('advscenario', 'advscenario_checkbox_root', 'advscenario_checkbox_root')\" id=\"advscenario_checkbox_root\">SelectAll</div>Test loop: <input id=\"loopadvscenario\" type=\"text\" name=\"loopPPAT\" value=\"1\" class=\"testloop\"/></th></tr>";
			for(var j = 0; j < powerAdvCategory_b.length; j++){
				table += "<tr><td class=\"category\"><input id=\"" + powerAdvCategory_b[i] + "_c\" father=\"advscenario_checkbox_root\" type=\"checkbox\" value=\"Select " + powerAdvCategory[j] + "\" onclick=\"ppat_CheckboxSelectAll('advscenario', '" + powerAdvCategory_b[i] + "_c', 'advscenario_checkbox_root')\">"+ powerAdvCategory[j] + "</td><td class=\"case\">";
				for(var k = 0; k < powerAdvancedCase.length; k++){
					if(powerAdvCategory[k] == powerAdvCategory_b[j] && platform[k] == pf){
						table += "<div><input id=\"" + powerAdvancedCase[k] + "\" type=\"checkbox\" father=\"" + powerAdvCategory_b[i] + "_c\" value=\"" + powerAdvCategory[k] + "\"" + " name=\"powerAdv\" class=\"" + powerAdvancedCase[k] + "\" text=\""+ powerAdvancedCase[k] +"\" onclick=\"ppat_CheckboxSelectAll('advscenario', '" + powerAdvancedCase[k] + "', '" + powerAdvCategory_b[i] + "_c')\">" + powerAdvancedCase[k] + "</div>";
					}
				}
			}
			table += "</td></tr></table></br>";
			adv_scenario_div.append(table);
		}
	}
}

function style(){
	$("table div").css({
		"width":"200px",
		"display": "inline-block",
	});
	$("table th").css({
	    "text-align":"left",
	    "height":"30px",
	    "background-color":"#e1e1e1",
	});
	$("table td").css({
		"text-align":"left",
	});
	$("#tune div").css("width","150px");
	$(".category").css({
		"width":"15%",
	    "background-color":"#f1f1f1",
	});
	$(".case").css("width", "85%");
	$(".1080p").colorbox({inline:true, width:"50%"});
	$(".720p").colorbox({inline:true, width:"50%"});
	$(".VGA").colorbox({inline:true, width:"50%"});
	$(".mp3").colorbox({inline:true, width:"50%"});
	$(".tabletitle").css({
	    "display":"inline-block",
	    "width":"197px",
	    "text-indent":"8px",
	});
	$(".testloop").css({
	    "width":"20",
	    "text-align":"center",
	});}

function addScenarioCheckbox(){
	var scenario_div = $("#scenario");
	scenario_div.html("");
	var table="<table id=\"scenario_table\" cellspacing=\"0px\" border=\"1\" width=\"100%\"><tr><th colspan=\"2\"><div class=\"tabletitle\">AP Power</div><div><input type=\"checkbox\" text=\"SelectAll\" value=\"Select All\" onclick=\"ppat_CheckboxSelectAll('scenario', 'scenario_checkbox_root', 'scenario_checkbox_root')\" id=\"scenario_checkbox_root\">SelectAll</div>Test loop: <input id=\"loopscenario\" type=\"text\" name=\"loopPPAT\" value=\"1\" class=\"testloop\"/></th></tr>";

	//add button to select/de-select by category
    powerCategory_b = powerCategory.concat();
    powerCategory_b = powerCategory_b.del();
    for(var i = 0; i < powerCategory_b.length; i++){
		table += "<tr><td class=\"category\"><input type=\"checkbox\" id=\"" + powerCategory_b[i] + "_c\" father=\"scenario_checkbox_root\" value=\"Select " + powerCategory_b[i] + "\" onclick=\"ppat_CheckboxSelectAll('scenario', '" + powerCategory_b[i] + "_c', 'scenario_checkbox_root')\">" + powerCategory_b[i] + "</div></td><td class=\"case\">";
			for(var j = 0; j < powerCase.length; j++){
				if(powerCategory[j] == powerCategory_b[i]){
					table +="<div><input id=\"child\" type=\"checkbox\" father=\"" + powerCategory_b[i] + "_c\" value=\"" + powerCategory[j] + "\"" + " name=\"power\" class=\"" + powerCase[j] + "\" text=\""+ powerCase[j] +"\" href=\"#"+ powerCase[j] +"\" onclick=\"ppat_CheckboxSelectAll('scenario', 'child', '" + powerCategory_b[i] + "_c')\">" + powerCase[j] + "</div>";
				}
    	}
		table += "</td></tr>"
    }
	table += "</table></br>";
	scenario_div.append(table);

	addAdvancedScenarioCheckbox(device);

	style();//control the hole page style
}

function addUIScenarioCheckbox(){
	var scenario_div = $("#ui");
	scenario_div.html("");
	var table="<table id=\"ui_table\" cellspacing=\"0px\" border=\"1\" width=\"100%\"><tr><th colspan=\"2\"><div class=\"tabletitle\">UI Performance</div><div><input type=\"checkbox\" text=\"SelectAll\" value=\"Select All\" onclick=\"ppat_CheckboxSelectAll('ui', 'ui_checkbox_root', 'ui_checkbox_root')\" id=\"ui_checkbox_root\">SelectAll</div>Test loop: <input id=\"loopui\" type=\"text\" name=\"loopPPAT\" value=\"1\" class=\"testloop\"/></th></tr>";

	//add button to select/de-select by category
    performanceCategory_b = performanceCategory.concat();
    performanceCategory_b = performanceCategory_b.del();
    for(var i = 0; i < performanceCategory_b.length; i++){
		var category = performanceCategory_b[i].replace(/\s+/g, "_");
		table += "<tr><td class=\"category\"><input type=\"checkbox\" id=\"" + category + "_c\" father=\"ui_checkbox_root\" value=\"Select " + performanceCategory_b[i] + "\" onclick=\"ppat_CheckboxSelectAll('ui', '" + category + "_c', 'ui_checkbox_root')\">" + performanceCategory_b[i] + " </td><td class=\"case\">";
			for(var j = 0; j < performanceCase.length; j++){
				if(performanceCategory[j] == performanceCategory_b[i]){
					table +="<div><input id=\"child\" type=\"checkbox\" father=\"" + category + "_c\" value=\"" + performanceCategory[j] + "\"" + " name=\"performance\" class=\"" + performanceCase[j] + "\" text=\""+ performanceCase[j] +"\" href=\"#"+ performanceCase[j] +"\" onclick=\"ppat_CheckboxSelectAll('ui', 'child', '" + category + "_c')\">" + performanceCase[j] + "</div>";
				}
    	}
		table += "</td></tr>"
    }
	table += "</table></br>";
	scenario_div.append(table);
	style();//control the hole page style
}

function ppat_addDeviceCase(j){
	var scenario_div = $("#scenario");
	$("#scenario_table").html("");
	scenario_div.html("");

	powerCategory_b = powerCategory.concat();
	powerCase_b = powerCase.concat();
	$(xmlDoc).find("Device").each(function(){
		if($(this).find("Name").text() == powerDevice[j].name){
			var tdVal="";
			$(this).find("CaseName").each(function(){
				powerCase_b.push($(this).text());
				powerCategory_b.push($(this).attr("Category"));
			});
		}
	});
	//reset table
	var table="<table id=\"scenario_table\" cellspacing=\"0px\" border=\"1\" width=\"100%\"><tr><th colspan=\"2\"><div class=\"tabletitle\">AP Power</div><div><input type=\"checkbox\" text=\"SelectAll\" value=\"Select All\" onclick=\"ppat_CheckboxSelectAll('scenario', 'scenario_checkbox_root', 'scenario_checkbox_root')\" id=\"scenario_checkbox_root\">SelectAll</div>Test loop: <input id=\"loopscenario\" type=\"text\" name=\"loopPPAT\" value=\"3\" class=\"testloop\"/></th></tr>";

	//add button to select/de-select by category
	powerCategory_c = powerCategory_b.concat();
	powerCategory_b = powerCategory_b.del();
	for(var i = 0; i < powerCategory_b.length; i++){
		var category = powerCategory_b[i].replace(/\//g, "_");
		table += "<tr><td class=\"category\"><input type=\"checkbox\" id=\"" + category + "_c\" father=\"scenario_checkbox_root\" value=\"Select " + powerCategory_b[i] + "\" onclick=\"ppat_CheckboxSelectAll('scenario', '" + category + "_c', 'scenario_checkbox_root')\">" + powerCategory_b[i] + "</div></td><td class=\"case\">";

		for(var j = 0; j < powerCase_b.length; j++){
			if(powerCategory_c[j] == powerCategory_b[i]){
				table +="<div><input id=\"child\" type=\"checkbox\" father=\"" + category + "_c\" value=\"" + powerCategory_c[j] + "\"" + " name=\"power\" class=\"" + powerCase_b[j] + "\" text=\""+ powerCase_b[j] +"\" href=\"#"+ powerCase_b[j] +"\" onclick=\"ppat_CheckboxSelectAll('scenario', 'child', '" + category + "_c')\">" + powerCase_b[j] + "</div>";
			}
		}
		table += "</td></tr>";
	}
	table += "</table></br>";
	scenario_div.append(table);

	addAdvancedScenarioCheckbox(device);
	style();//control the hole page style
}

function veryfyBlur(val){
	var volVal = val.value.split(",");
		for(var i = 0; i < volVal.length; i++){
			if(volVal[i].trim().match(/\D/) != null){
				alert("voltage must be number and range: [600, 1500]");
				return;
			}
			var vol = parseInt(volVal[i].trim());
			if(vol > 1500 || vol < 600){
				alert("voltage must be range: [600, 1500]");
				return;
			}
		}
}

function verify(val){
	if(val.value.charAt(val.value.length - 1) == ","){
		var volVal = val.value.split(",");
		for(var i = 0; i < volVal.length; i++){
			if(volVal[i].trim().match(/\D/) != null){
				alert("voltage must be number and range: [600, 1500]");
				return;
			}
			var vol = parseInt(volVal[i].trim());
			if(vol > 1500 || vol < 600){
				alert("voltage must be range: [600, 1500]");
				return;
			}
		}
	}
}

function ppat_appendToText(v){
    var jsonStr = "";
    var caseCount = 0;
	var scenarios = $("#scenario").find("input");
	scenarios.each(function(){
		if($(this).attr("checked") && $(this).attr("name")){
			caseCount += 1;
			jsonStr += "{\"Name\":\"" + $(this).attr("text") + "\",\"Property\":{";

			//stream etc property
			if(property[$(this).attr("text")]){
				jsonStr += property[$(this).attr("text")] + ",";
			}
			
			//loop
		    var lp = $("#loopscenario").val();
		    if(lp != ""){
		    	jsonStr +="\"count\":\"" + $("#loopscenario").val() + "\"}},";
		    }else{
				jsonStr +="\"count\":\"1\"}},";
			}
		}
	});
	//Param for baremetal test
	var ubootDiv = $("#baremetal");
	//find all test case by class
	$("#baremetal table").each(function(){
		var totalParamNum = $(this).find("tr").length - 1;
		var paramCount = 0;
		var propertyStr = "";

		var caseId = $(this).parent().attr("id");
			var compFreqInfo = "";
			var property = "";
			$(this).find("td").each(function(){
				var checked = false;
				var compName = "";
				var compInfo = "";
				//var compFreqInfo = "";
				$(this).find("input").each(function(){
					if($(this).attr("type") == "text"){
						if($(this).val()){
							paramCount += 1;
							var value = $(this).val().replace(/\"/g, '&quot;'); //get input text value
							var name = $(this).attr("name");
							if(name.indexOf("vol") != -1){
								name = "VL";
							}
							property += "\"" + name + "\":\"" + value + "\",";
						}
					}else{
						if($(this).prop('checked')){
							compName = $(this).attr("param");
							checked = true;
							compInfo += $(this).attr("text") + ",";
						}
					}
				});
				//collect freq info
				if(checked && compInfo != ""){
					paramCount += 1;
					compFreqInfo += "\"" + compName.toUpperCase() +"\":\"" + compInfo.substring(0, compInfo.length - 1) + "\",";
				}
				propertyStr = ",\"Property\":{" + property + compFreqInfo.substring(0, compFreqInfo.length - 1)+ "}}";
			});

			if(compFreqInfo != ""){
				propertyStr += ",";
			}
			if(paramCount == totalParamNum){
			caseCount += 1;
			jsonStr += "{\"Name\":\"" + caseId + "\"";
			jsonStr += propertyStr;

		}
	});
	var advscenarios = $("#advscenario").find("input");
	advscenarios.each(function(){
		if($(this).attr("checked") && $(this).attr("name")){
			caseCount += 1;
			jsonStr += "{\"Name\":\"" + $(this).attr("text") + "\",\"Property\":{";

			//loop
		    var lp = $("#loopadvscenario").val();
		    if(lp != ""){
		     	jsonStr +="\"count\":\"" + $("#loopadvscenario").val() + "\"}},";
		    }else{
				jsonStr +="\"count\":\"1\"}},";
			}
		}
	});
	var ui = $("#ui").find("input");
	ui.each(function(){
		if($(this).attr("checked") && $(this).attr("name")){
			caseCount += 1;
			jsonStr += "{\"Name\":\"" + $(this).attr("text") + "\",\"Property\":{";

			//loop
		    var lp = $("#loopui").val();
		    if(lp != ""){
		     	jsonStr +="\"count\":\"" + $("#loopui").val() + "\"}},";
		    }else{
				jsonStr +="\"count\":\"1\"}},";
			}
		}
	});
	if(caseCount >= 1){
		jsonStr = "{\"TestCaseList\":[" + jsonStr.substring(0, jsonStr.length - 1) + "]";
		for(var c = 1; c <= countOfCmds; c++){
			if($("#"+c).val() != "" && $("#"+c).val() != null){
			jsonStr +=",\"roundcmd\":[";
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

//Param for baremetal test
		var baremetalParam = "";
		$("table#ubootParam .component").each(function(){
			$(this).find("div").each(function(){
				var component_vl = $(this).attr("id");
				var compInfo = "";
				$(this).find("input").each(function(){
					if($(this).attr("checked")){
						compInfo += $(this).attr("name") + ",";
					}
				});
				if(compInfo != ""){
					baremetalParam += "\"" + component_vl + "\":\"";
					compInfo = compInfo.substring(0, compInfo.length - 1) + "\",";
					baremetalParam += compInfo;
				}

			});
		});
		var coreInfo = "";
		$("table#ubootParam #CoreNum").each(function(){
			$(this).find("div").each(function(){
				$(this).find("input").each(function(){
					if($(this).attr("checked")){
						coreInfo += $(this).attr("name") + ",";
					}
				});

			});
		});
		if(coreInfo != ""){
			baremetalParam += "\"CoreNum\":\"";
			coreInfo = coreInfo.substring(0, coreInfo.length - 1) + "\",";
			baremetalParam += coreInfo;
		}
		var volInfo = "";
		var volevlInfo = "";
		$("table#ubootParam #vol").each(function(){
			$(this).find("div").each(function(){
				$(this).find("input").each(function(){
					if($(this).attr("checked")){
						volInfo += "\"" + $(this).attr("param") + "\":\"" + $(this).attr("name") + "\",";
						volevlInfo += $(this).attr("param") + ",";
					}
				});

			});
		});
		if(volInfo != ""){
			volInfo = volInfo.substring(0, volInfo.length - 1);
			baremetalParam += volInfo;
			baremetalParam += ",\"VL\":\"" + volevlInfo.substring(0, volevlInfo.length - 1) + "\",";
		}
		if(baremetalParam != ""){
			jsonStr += ",\"bareParam\":{" + baremetalParam.substring(0, baremetalParam.length - 1) + "}";
		}
//Param for Round PP Tuning
		var tuneParam ="";
//CPU
		var cpu = "";
		var tune = $(".cpu").each(function(){
			var param = "";
			var paramVal = "";
			$(this).find("input").each(function(){
				if($(this).attr("param") != param){
					param = $(this).attr("param");
					paramVal = "";
				}
				if($(this).attr("type") == "checkbox"){
					if($(this).attr("checked")){
						paramVal += $(this).attr("name") + ",";
					}
					}else{//text
						if($(this).val() != ""){
							paramVal += $(this).val() + ",";
						}
					}
			});
			if(paramVal != ""){
				cpu += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
			}
		});
		if(cpu != ""){
			cpu = "\"cpu\":{" + cpu.substring(0,cpu.length-1) + "},";
			tuneParam += cpu;
		}
//DDR
		var ddr = "";
		var tune = $(".ddr").each(function(){
			var param = "";
			var paramVal = "";
			$(this).find("input").each(function(){
				if($(this).attr("param") != param){
					param = $(this).attr("param");
					paramVal = "";
				}
				if($(this).attr("type") == "checkbox"){
					if($(this).attr("checked")){
						paramVal += $(this).attr("name") + ",";
					}
				}else{//text
					if($(this).val() != ""){
						paramVal += $(this).val() + ",";
					}
				}
			});
			if(paramVal != ""){
				ddr += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
			}
		});
		if(ddr != ""){
			ddr = "\"ddr\":{" + ddr.substring(0,ddr.length-1) + "},";
			tuneParam += ddr;
		}
//gpu0
		var gpu0 = "";
		var tune = $(".gpu0").each(function(){
			var param = "";
			var paramVal = "";
			$(this).find("input").each(function(){
				if($(this).attr("param") != param){
					param = $(this).attr("param");
					paramVal = "";
				}
				if($(this).attr("type") == "checkbox"){
					if($(this).attr("checked")){
						paramVal += $(this).attr("name") + ",";
					}
				}else{//text
					if($(this).val() != ""){
						paramVal += $(this).val() + ",";
					}
				}
			});
			if(paramVal != ""){
				gpu0 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
			}
		});
		if(gpu0 != ""){
			gpu0 = "\"gpu0\":{" + gpu0.substring(0,gpu0.length-1) + "},";
			tuneParam += gpu0;
		}
//gpu1
		var gpu1 = "";
		var tune = $(".gpu1").each(function(){
			var param = "";
			var paramVal = "";
			$(this).find("input").each(function(){
				if($(this).attr("param") != param){
					param = $(this).attr("param");
					paramVal = "";
				}
				if($(this).attr("type") == "checkbox"){
					if($(this).attr("checked")){
						paramVal += $(this).attr("name") + ",";
					}
				}else{//text
					if($(this).val() != ""){
						paramVal += $(this).val() + ",";
					}
				}
			});
			if(paramVal != ""){
				gpu1 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
			}
		});
		if(gpu1 != ""){
			gpu1 = "\"gpu1\":{" + gpu1.substring(0,gpu1.length-1) + "},";
			tuneParam += gpu1;
		}
//vpu0
		var vpu0 = "";
		var tune = $(".vpu0").each(function(){
			var param = "";
			var paramVal = "";
			$(this).find("input").each(function(){
				if($(this).attr("param") != param){
					param = $(this).attr("param");
					paramVal = "";
				}
				if($(this).attr("type") == "checkbox"){
					if($(this).attr("checked")){
						paramVal += $(this).attr("name") + ",";
					}
				}else{//text
					if($(this).val() != ""){
						paramVal += $(this).val() + ",";
					}
				}
			});
			if(paramVal != ""){
				vpu0 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
			}
		});
		if(vpu0 != ""){
			vpu0 = "\"vpu0\":{" + vpu0.substring(0,vpu0.length-1) + "},";
			tuneParam += vpu0;
		}
//vpu1
		var vpu1 = "";
		var tune = $(".vpu1").each(function(){
			var param = "";
			var paramVal = "";
			$(this).find("input").each(function(){
				if($(this).attr("param") != param){
					param = $(this).attr("param");
					paramVal = "";
				}
				if($(this).attr("type") == "checkbox"){
					if($(this).attr("checked")){
						paramVal += $(this).attr("name") + ",";
					}
				}else{//text
					if($(this).val() != ""){
						paramVal += $(this).val() + ",";
					}
				}
			});
			if(paramVal != ""){
				vpu1 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
			}
		});
		if(vpu1 != ""){
			vpu1 = "\"vpu1\":{" + vpu1.substring(0,vpu1.length-1) + "},";
			tuneParam += vpu1;
		}
//all tune append to jsonStr
		if(tuneParam != ""){
			jsonStr += ",\"roundpp\":{" + tuneParam.substring(0,tuneParam.length-1) + "}";
		}
        jsonStr += "}";
        jsonStr = jsonStr.replace(/[\n]/ig,'&amps;').replace(/\s+/g,'&nbsp;');

		$("input[name='" + v + "']").each(function(){
			$(this).attr("value", jsonStr);
		});
    }else{
        alert('Please at least choose a Power or Performance test case');
    }
}

function ppat_changeChildrenState(id, father, self){
	if($("#" + father).attr("checked")){//if parent checked, then all children should be checked
		$("#" + id).find(":checkbox").each(function(){
			if($(this).attr("father") == father){
				$(this).attr("checked", true);
			}

		});
	}else{//uncheck all child checkbox
		$("#" + id).find(":checkbox").each(function(){
			if($(this).attr("father")){
				if($(this).attr("father") == father){
					$(this).attr("checked", false);
				}
			}
		});
	}

}

function ppat_changeParentState(id, father, self){
	var state = true;
	$("#" + id).find(":checkbox").each(function(){
		if($(this).attr("father") == father){
				if(!$(this).attr("checked")){
					state = false;
				}
			}
	});
	$("#" + father).attr("checked", state);

}

function ppat_CheckboxSelectAll(id, father, grandfarther) {
	//change children state
	ppat_changeChildrenState(id, father, "");
	if($("#" + father).attr("checked")){//if parent checked, then all children should be checked
		$("#" + id).find(":checkbox").each(function(){
			if($(this).attr("father") == father){
				ppat_changeChildrenState(id, $(this).attr("id"), "");
			}

		});
	}else{//uncheck all child checkbox
		$("#" + id).find(":checkbox").each(function(){
			if($(this).attr("father")){
				if($(this).attr("father") == father){
					ppat_changeChildrenState(id, $(this).attr("id"), "");
				}
			}
		});
	}
	if(typeof($("#" + father).attr("father"))!="undefined"){
		var state = true;
		$("#" + id).find(":checkbox").each(function(){
			if($(this).attr("father") == grandfarther){
					if(!$(this).attr("checked")){
						state = false;
					}
				}
		});
		$("#" + grandfarther).attr("checked", state);
		if(typeof($("#" + grandfarther).attr("father"))!="undefined"){
			ppat_changeParentState(id, $("#" + grandfarther).attr("father"), self);
		}
	}
 }

function ppat_CheckboxSelectCategory(name, Category, id) {
  if($(name).attr("checked")){
		$(id).find(":checkbox").each(function(){
			if($(this).attr("value") == Category){
				$(this).attr("checked", true);
			}
		});
	}else{
		$(id).find(":checkbox").each(function(){
			if($(this).attr("value") == Category){
				$(this).attr("checked", false);
			}
		});
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
        if (selected.value == "ppat_test")
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
        var sel = document.getElementById("property6value");
        var op = sel.options[sel.selectedIndex];
        var r_devices = blfArr[op.text];
        var r_device = document.getElementById("property7value");
        r_device.length=0;
        for(var i=0;i<r_devices.length;i++){
        var ops = new Option();
        ops.text = r_devices[i] ;
        r_device.options[i] = ops;
        }
		device = op.text;
        $("#DeviceHW").css("display", "none");
		$("#DeviceHW").empty();
        $("#device_module").remove();
        $("#DeviceHW").append("<b>Choose Board HW Module:</b><div id=\"device_module\"></div>");
        for(var i = 0; i < boardDevice.length; i++){
            if(boardDevice[i].type == op.text){
                var hwModule = new Array();
                hwModule = boardDevice[i].hw.split(";");
                for(var k = 0; k < hwModule.length; k++){
                    for(var j = 0; j < powerDevice.length; j++){
                        if(powerDevice[j].name == hwModule[k]){
                            $("#DeviceHW").css("display", "block");
							$("#DeviceHW").append("<input id=\"" + powerDevice[j].name + "\" type=\"radio\" value=\"" + powerDevice[j].name + "\"" + " name=\"device\" onclick=ppat_addDeviceCase(" + j + ")>" + powerDevice[j].name);
                        }
                     }
                 }
            }
        }
		addScenarioCheckbox();
        updateTable(testType);
}

function branchSelect3(){
        var sel = document.getElementById("property8value");
        var op = sel.options[sel.selectedIndex];
        var r_devices = blfArr[op.text];
        var r_device = document.getElementById("property9value");
        r_device.length=0;
        for(var i=0;i<r_devices.length;i++){
        var ops = new Option();
        ops.text = r_devices[i] ;
        r_device.options[i] = ops;
        }
		device = op.text;
		$("#DeviceHW").css("display", "none");
		$("#DeviceHW").empty();
        $("#device_module").remove();
        $("#DeviceHW").append("<b>Choose Board HW Module:</b><div id=\"device_module\"></div>");
        for(var i = 0; i < boardDevice.length; i++){
            if(boardDevice[i].type == op.text){
                var hwModule = new Array();
                hwModule = boardDevice[i].hw.split(";");
                for(var k = 0; k < hwModule.length; k++){
                    for(var j = 0; j < powerDevice.length; j++){
                        if(powerDevice[j].name == hwModule[k]){
                            $("#DeviceHW").css("display", "block");
							$("#DeviceHW").append("<input id=\"" + powerDevice[j].name + "\" type=\"radio\" value=\"" + powerDevice[j].name + "\"" + " name=\"device\" onclick=ppat_addDeviceCase(" + j + ")>" + powerDevice[j].name);
                        }
                     }
                 }
            }
        }
		addScenarioCheckbox();
        updateTable(testType);
}
